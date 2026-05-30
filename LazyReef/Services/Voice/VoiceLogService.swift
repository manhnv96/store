//
//  VoiceLogService.swift
//  LazyReef
//
//  Wraps Apple's Speech framework + AVAudioEngine to capture vi-VN speech and
//  expose a live transcription as `@Observable` state. UI consumes this and feeds
//  the final transcription into `VoiceLogParser`.
//

import AVFoundation
import Foundation
import Speech

enum VoiceAuthStatus: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case unavailable
}

enum VoiceLogError: Equatable, Error {
    case recognizerUnavailable
    case audioSessionFailed
    case engineFailed(String)
    case recognitionFailed(String)
}

@Observable
@MainActor
final class VoiceLogService {

    private(set) var transcription: String = ""
    private(set) var isListening: Bool = false
    private(set) var authStatus: VoiceAuthStatus = .notDetermined
    private(set) var lastError: VoiceLogError?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func requestAuthorization() async {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        let microphoneGranted = await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }

        switch (speechStatus, microphoneGranted) {
        case (.authorized, true):
            authStatus = (recognizer?.isAvailable == true) ? .authorized : .unavailable
        case (.denied, _), (_, false):
            authStatus = .denied
        case (.restricted, _):
            authStatus = .restricted
        case (.notDetermined, _):
            authStatus = .notDetermined
        @unknown default:
            authStatus = .denied
        }
    }

    func start() {
        guard !isListening else { return }
        guard authStatus == .authorized, let recognizer, recognizer.isAvailable else {
            lastError = .recognizerUnavailable
            return
        }

        transcription = ""
        lastError = nil

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            lastError = .audioSessionFailed
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            lastError = .engineFailed(error.localizedDescription)
            cleanup()
            return
        }

        isListening = true

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.transcription = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.stop()
                    }
                }
                if let error {
                    self.lastError = .recognitionFailed(error.localizedDescription)
                    self.stop()
                }
            }
        }
    }

    func stop() {
        guard isListening else {
            cleanup()
            return
        }
        request?.endAudio()
        cleanup()
        isListening = false
    }

    private func cleanup() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        task?.cancel()
        task = nil
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
