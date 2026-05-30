//
//  VoiceLogSheet.swift
//  LazyReef
//
//  Voice-driven log entry: listen → transcribe → parse → confirm + save.
//

import SwiftUI

struct VoiceLogSheet: View {

    let aquariumID: UUID
    let aquariumName: String
    /// Called once per saved reading.
    let onSave: (WaterReading) -> Void

    @State private var voice = VoiceLogService()
    @State private var pulse = false
    @State private var hasStopped = false
    @State private var editingPrefill: ParsedReading?
    @State private var silenceTask: Task<Void, Never>?
    @State private var didAutoStart = false

    @Environment(\.dismiss) private var dismiss

    /// Auto-stop after this much silence (no new transcription) while listening.
    private let silenceTimeout: Duration = .milliseconds(1500)

    private var parsed: [ParsedReading] {
        VoiceLogParser.parse(voice.transcription)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(Language.VoiceLog.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Language.Log.cancel) {
                            voice.stop()
                            dismiss()
                        }
                    }
                }
                .task {
                    if voice.authStatus == .notDetermined {
                        await voice.requestAuthorization()
                    }
                    autoStartIfPossible()
                }
                .sheet(item: $editingPrefill) { prefill in
                    LogEntryFormView(
                        aquariumID: aquariumID,
                        editing: nil,
                        prefill: prefill
                    ) { reading, _ in
                        onSave(reading)
                    }
                }
                .onChange(of: voice.isListening) { _, listening in
                    pulse = listening
                    if !listening {
                        silenceTask?.cancel()
                    }
                }
                .onChange(of: voice.transcription) { _, _ in
                    scheduleSilenceAutoStop()
                }
                .onDisappear {
                    silenceTask?.cancel()
                    voice.stop()
                }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private var content: some View {
        switch voice.authStatus {
        case .denied, .restricted, .unavailable:
            permissionDeniedView
        default:
            listenView
        }
    }

    // MARK: - Listen / Preview

    private var listenView: some View {
        VStack(spacing: 24) {
            header

            if voice.isListening {
                pulsingMic
            } else {
                idleMic
            }

            transcriptionDisplay

            Spacer()

            if hasStopped && parsed.isEmpty {
                noMatchView
            } else if !parsed.isEmpty {
                previewList
            }

            actionButton
                .padding(.bottom, 8)
        }
        .padding(20)
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text(Language.Aquarium.pickerTitle + ": " + aquariumName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(Language.VoiceLog.hint)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var pulsingMic: some View {
        ZStack {
            Circle()
                .fill(Color.red.opacity(0.18))
                .frame(width: 140, height: 140)
                .scaleEffect(pulse ? 1.15 : 0.95)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
            Circle()
                .fill(Color.red.opacity(0.28))
                .frame(width: 100, height: 100)
            Image(systemName: "mic.fill")
                .font(.system(size: 36))
                .foregroundStyle(.white)
                .padding(28)
                .background(Color.red, in: Circle())
        }
    }

    private var idleMic: some View {
        Image(systemName: "mic.slash")
            .font(.system(size: 60))
            .foregroundStyle(.secondary)
            .padding(36)
            .background(Color.gray.opacity(0.12), in: Circle())
    }

    private var transcriptionDisplay: some View {
        Group {
            if voice.transcription.isEmpty {
                Text(voice.isListening ? Language.VoiceLog.listening : Language.VoiceLog.tapToStart)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text(voice.transcription)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
        .frame(minHeight: 50)
    }

    private var previewList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Language.VoiceLog.previewTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(parsed, id: \.self) { reading in
                previewRow(reading)
            }

            Button {
                saveAll()
            } label: {
                Text(Language.VoiceLog.confirmAll)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
            .padding(.top, 4)
        }
    }

    private func previewRow(_ reading: ParsedReading) -> some View {
        let plausible = VoiceLogParser.plausibleRange(for: reading.parameter).contains(reading.value)
        return HStack(spacing: 12) {
            Image(systemName: reading.parameter.iconSystemName)
                .foregroundStyle(.blue)
                .frame(width: 28, height: 28)
                .background(Color.blue.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("\(reading.parameter.title) = \(displayValue(reading))")
                        .font(.subheadline.weight(.semibold))
                    if !reading.parameter.unit.isEmpty {
                        Text(reading.parameter.unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if !plausible {
                    Label(Language.Log.plausibleWarning, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
            Button {
                editingPrefill = reading
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }

    private var noMatchView: some View {
        VStack(spacing: 8) {
            Image(systemName: "questionmark.bubble")
                .font(.title)
                .foregroundStyle(.secondary)
            Text(Language.VoiceLog.noMatch)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }

    private var actionButton: some View {
        Button {
            toggleListening()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: voice.isListening ? "stop.fill" : "mic.fill")
                Text(voice.isListening ? Language.VoiceLog.stop : (hasStopped ? Language.VoiceLog.retry : Language.VoiceLog.title))
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(voice.isListening ? Color.red : Color.blue, in: Capsule())
            .foregroundStyle(.white)
        }
    }

    // MARK: - Permission denied

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text(Language.VoiceLog.permissionDenied)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(Language.VoiceLog.permissionInstruction)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Mở Cài đặt")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue, in: Capsule())
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(24)
    }

    // MARK: - Actions

    private func toggleListening() {
        if voice.isListening {
            voice.stop()
            hasStopped = true
        } else {
            hasStopped = false
            voice.start()
        }
    }

    /// Auto-start listening the first time the sheet appears, once permission is granted.
    /// Re-opens of the sheet do trigger this again because state resets per presentation.
    private func autoStartIfPossible() {
        guard !didAutoStart,
              voice.authStatus == .authorized,
              !voice.isListening else { return }
        didAutoStart = true
        voice.start()
    }

    /// Restart the silence countdown each time a partial transcription update arrives.
    /// When the timeout elapses without further updates and we have something parseable,
    /// stop listening so the user can review.
    private func scheduleSilenceAutoStop() {
        silenceTask?.cancel()
        guard voice.isListening, !voice.transcription.isEmpty else { return }
        let timeout = silenceTimeout
        silenceTask = Task { @MainActor in
            try? await Task.sleep(for: timeout)
            guard !Task.isCancelled else { return }
            guard voice.isListening else { return }
            voice.stop()
            hasStopped = true
        }
    }

    private func saveAll() {
        let now = Date()
        for r in parsed {
            let reading = WaterReading(
                aquariumID: aquariumID,
                type: r.parameter,
                value: r.value,
                timestamp: now,
                source: .voice,
                note: nil,
                createdAt: now,
                updatedAt: now
            )
            onSave(reading)
        }
        voice.stop()
        dismiss()
    }

    private func displayValue(_ reading: ParsedReading) -> String {
        switch reading.parameter {
        case .ph, .temperature, .oxygen:
            return String(format: "%.1f", reading.value)
        case .po4:
            return String(format: "%.2f", reading.value)
        case .salinity:
            return String(format: "%.3f", reading.value)
        default:
            return String(format: "%.0f", reading.value)
        }
    }
}

extension ParsedReading: Identifiable {
    var id: String { "\(parameter.rawValue)-\(value)-\(raw)" }
}

#if DEBUG
#Preview {
    VoiceLogSheet(aquariumID: UUID(), aquariumName: "Bể chính") { _ in }
}
#endif
