//
//  LogEntryFormView.swift
//  LazyReef
//
//  Manual entry / edit sheet for a water parameter reading.
//

import SwiftUI

struct LogEntryFormView: View {

    let aquariumID: UUID
    let editing: WaterReading?
    /// Prefilled defaults coming from a parsed voice utterance.
    let prefill: ParsedReading?
    /// Called with the final reading and a flag indicating whether it was an edit.
    let onSave: (WaterReading, Bool) -> Void

    @State private var parameter: WaterParameterType
    @State private var valueText: String
    @State private var timestamp: Date
    @State private var note: String
    @State private var showPlausibleWarning = false
    @State private var attemptedSave = false

    @Environment(\.dismiss) private var dismiss
    @FocusState private var valueFocused: Bool

    init(
        aquariumID: UUID,
        editing: WaterReading? = nil,
        prefill: ParsedReading? = nil,
        onSave: @escaping (WaterReading, Bool) -> Void
    ) {
        self.aquariumID = aquariumID
        self.editing = editing
        self.prefill = prefill
        self.onSave = onSave

        let initialParam = editing?.type ?? prefill?.parameter ?? .ph
        self._parameter = State(initialValue: initialParam)
        let initialValue: String
        if let editing {
            initialValue = String(editing.value)
        } else if let prefill {
            initialValue = String(prefill.value)
        } else {
            initialValue = ""
        }
        self._valueText = State(initialValue: initialValue)
        self._timestamp = State(initialValue: editing?.timestamp ?? .now)
        self._note = State(initialValue: editing?.note ?? "")
    }

    private var isEditing: Bool { editing != nil }

    private var parsedValue: Double? {
        Double(valueText.replacingOccurrences(of: ",", with: "."))
    }

    private var canSave: Bool {
        guard let v = parsedValue else { return false }
        return v.isFinite
    }

    private var isOutsidePlausibleRange: Bool {
        guard let v = parsedValue else { return false }
        return !VoiceLogParser.plausibleRange(for: parameter).contains(v)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Language.LogForm.parameter) {
                    Picker(Language.LogForm.parameter, selection: $parameter) {
                        ForEach(WaterParameterType.allCases) { type in
                            Label {
                                if type.unit.isEmpty {
                                    Text(type.title)
                                } else {
                                    Text("\(type.title) (\(type.unit))")
                                }
                            } icon: {
                                Image(systemName: type.iconSystemName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(Language.LogForm.value) {
                    HStack {
                        TextField(Language.LogForm.valuePlaceholder, text: $valueText)
                            .keyboardType(.decimalPad)
                            .focused($valueFocused)
                        if !parameter.unit.isEmpty {
                            Text(parameter.unit)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if attemptedSave && isOutsidePlausibleRange {
                        Label(Language.Log.plausibleWarning, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                Section(Language.LogForm.timestamp) {
                    DatePicker(
                        Language.LogForm.timestamp,
                        selection: $timestamp,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                }

                Section(Language.LogForm.note) {
                    TextField(
                        Language.LogForm.notePlaceholder,
                        text: $note,
                        axis: .vertical
                    )
                    .lineLimit(2...5)
                }
            }
            .navigationTitle(isEditing ? Language.LogForm.editTitle : Language.LogForm.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Language.Log.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Language.LogForm.save) {
                        attemptSave()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                valueFocused = (editing == nil && prefill == nil)
            }
        }
        .alert(Language.Log.plausibleWarning, isPresented: $showPlausibleWarning) {
            Button(Language.Log.cancel, role: .cancel) {}
            Button(Language.LogForm.save) {
                commitSave()
            }
        } message: {
            if let v = parsedValue {
                let range = VoiceLogParser.plausibleRange(for: parameter)
                Text("\(parameter.title) = \(formatted(v)) ngoài khoảng hợp lý (\(formatted(range.lowerBound)) – \(formatted(range.upperBound)) \(parameter.unit)).")
            }
        }
    }

    private func attemptSave() {
        attemptedSave = true
        guard let _ = parsedValue else { return }
        if isOutsidePlausibleRange {
            showPlausibleWarning = true
            return
        }
        commitSave()
    }

    private func commitSave() {
        guard let value = parsedValue else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date()
        let reading: WaterReading
        if let existing = editing {
            reading = WaterReading(
                id: existing.id,
                aquariumID: existing.aquariumID,
                type: parameter,
                value: value,
                timestamp: timestamp,
                source: existing.source,
                note: trimmedNote.isEmpty ? nil : trimmedNote,
                createdAt: existing.createdAt,
                updatedAt: now
            )
        } else {
            reading = WaterReading(
                aquariumID: aquariumID,
                type: parameter,
                value: value,
                timestamp: timestamp,
                source: prefill == nil ? .manual : .voice,
                note: trimmedNote.isEmpty ? nil : trimmedNote,
                createdAt: now,
                updatedAt: now
            )
        }
        onSave(reading, isEditing)
        dismiss()
    }

    private func formatted(_ v: Double) -> String {
        switch parameter {
        case .ph, .temperature, .oxygen:
            return String(format: "%.1f", v)
        case .po4:
            return String(format: "%.2f", v)
        case .salinity:
            return String(format: "%.3f", v)
        default:
            return String(format: "%.0f", v)
        }
    }
}

#if DEBUG
#Preview {
    LogEntryFormView(aquariumID: UUID()) { _, _ in }
}
#endif
