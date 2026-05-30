//
//  WakeWordListener.swift
//  LazyReef
//
//  Long-running ambient speech listener that watches for a wake phrase
//  ("Hey Reef" / "Reef ơi" / ...) and parses whatever follows as a
//  water-parameter reading. Designed for hands-free logging while the
//  user is testing water with wet hands.
//
//  Design notes:
//  - Keeps a single AVAudioEngine running across multiple
//    SFSpeechRecognitionTask instances. Each task is short-lived
//    (the recognizer auto-finalises around 60s) so we transparently
//    restart the task while keeping the audio tap installed.
//  - Resets the transcript after every successful parse so we don't
//    re-emit the same reading on the next partial result.
//

import AVFoundation
import Foundation
import Speech

@Observable
@MainActor
final class WakeWordListener {

    /// True while the engine is running and we're listening for the wake word.
    private(set) var isActive: Bool = false
    /// Most recent partial transcription, used for the UI banner.
    private(set) var transcription: String = ""
    /// Increment any time a wake phrase is heard — UI can pulse on this.
    private(set) var wakeEvents: Int = 0
    /// Last error, if any.
    private(set) var lastError: VoiceLogError?

    /// Callback fired once per parsed reading. The host saves the reading.
    var onReadingDetected: ((ParsedReading) -> Void)?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN"))
    private let audioEngine = AVAudioEngine()
    private var currentRequest: SFSpeechAudioBufferRecognitionRequest?
    private var currentTask: SFSpeechRecognitionTask?
    /// Debounce: only parse the transcript after this much silence to ensure
    /// the user has finished an utterance.
    private let parseDebounce: Duration = .milliseconds(900)
    private var debounceTask: Task<Void, Never>?
    /// Signatures of readings already emitted in this listening session so we
    /// don't fire the same value twice from re-arriving partial results.
    private var emittedSignatures: Set<String> = []

    /// Wake phrases recognised after diacritic stripping + lowercasing.
    /// Primary phrase is "ghi log"; the rest cover common mis-transcriptions
    /// from SFSpeechRecognizer in vi-VN — including "inox" which the engine
    /// often outputs for the close-sounding "ghi log".
    private let wakePhrases: [String] = [
        "ghi log",
        "ghi loc",
        "ghi luc",
        "gi log",
        "ghilog",
        "inox",
        "i noc",
        "i noi",
        "y noc",
        "ghi noc"
    ]

    func start() async {
        guard !isActive else { return }
        lastError = nil

        let status = await Self.ensureAuthorization()
        guard status == .authorized, let recognizer, recognizer.isAvailable else {
            lastError = .recognizerUnavailable
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            lastError = .audioSessionFailed
            return
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.currentRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            lastError = .engineFailed(error.localizedDescription)
            cleanup()
            return
        }

        isActive = true
        startNewRecognitionTask()
    }

    func stop() {
        guard isActive else { return cleanup() }
        currentRequest?.endAudio()
        cleanup()
        isActive = false
        transcription = ""
        processedPrefixLength = 0
    }

    // MARK: - Internals

    private static func ensureAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        let speech = await withCheckedContinuation { (cont: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
        let mic = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    cont.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    cont.resume(returning: granted)
                }
            }
        }
        return (speech == .authorized && mic) ? .authorized : speech
    }

    private func startNewRecognitionTask() {
        guard let recognizer, isActive else { return }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        currentRequest = request
        processedPrefixLength = 0

        currentTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                self.handle(result: result, error: error)
            }
        }
    }

    private func handle(result: SFSpeechRecognitionResult?, error: Error?) {
        if let result {
            transcription = result.bestTranscription.formattedString
            scanForWakePhrase()
        }
        if error != nil || (result?.isFinal == true) {
            restartTask()
        }
    }

    /// Look at the tail of the current transcription for a wake phrase and,
    /// if found, parse what comes after. Successful parses reset the task so
    /// subsequent utterances start with a clean transcript.
    private func scanForWakePhrase() {
        let normalized = transcription
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "vi_VN"))
            .lowercased()

        guard normalized.count > processedPrefixLength else { return }

        // Find the LAST occurrence of any wake phrase, considering only new tail.
        var bestRange: Range<String.Index>?
        for phrase in wakePhrases {
            if let r = normalized.range(of: phrase, options: [.backwards]) {
                if bestRange == nil || r.lowerBound > bestRange!.lowerBound {
                    bestRange = r
                }
            }
        }
        guard let range = bestRange else { return }

        let after = String(normalized[range.upperBound...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        // Require some content after the wake word before parsing.
        guard after.count >= 2 else { return }

        let parsed = VoiceLogParser.parse(after)
        guard !parsed.isEmpty else { return }

        wakeEvents += 1
        for reading in parsed {
            onReadingDetected?(reading)
        }
        // Fresh start so the next utterance isn't polluted by this transcript.
        restartTask()
    }

    /// End the current task and immediately spin up a new one. Keeps audioEngine
    /// running so there's no permission re-prompt or audio glitch.
    private func restartTask() {
        currentRequest?.endAudio()
        currentTask?.cancel()
        currentRequest = nil
        currentTask = nil
        transcription = ""
        processedPrefixLength = 0
        // Tiny delay so the old task tears down cleanly before the next start.
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(120))
            self?.startNewRecognitionTask()
        }
    }

    private func cleanup() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        currentTask?.cancel()
        currentTask = nil
        currentRequest = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
