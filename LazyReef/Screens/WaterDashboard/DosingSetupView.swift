//
//  DosingSetupView.swift
//  Store
//

import SwiftUI

struct DosingSetupView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var setup: DosingSetup

    private let onSave: (DosingSetup) -> Void

    init(setup: DosingSetup, onSave: @escaping (DosingSetup) -> Void) {
        _setup = State(initialValue: setup)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                frequencySection
                startTimeSection
                autoDosingSection
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(setup)
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Frequency

    private var frequencySection: some View {
        Section {
            ForEach(DosingFrequency.allCases) { freq in
                Button {
                    setup.frequency = freq
                } label: {
                    HStack {
                        Text(freq.title)
                            .foregroundStyle(.primary)
                        Spacer()
                        if setup.frequency == freq {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        } header: {
            Text("Frequency")
        } footer: {
            Text("How many times per day the system reads and doses.")
        }
    }

    // MARK: - Start Time

    private var startTimeSection: some View {
        Section {
            DatePicker(
                "Start Time",
                selection: $setup.startTime,
                displayedComponents: .hourAndMinute
            )
        } header: {
            Text("Start Time")
        } footer: {
            Text("The first reading/dosing of the day. Subsequent ones are evenly spaced.")
        }
    }

    // MARK: - Auto Dosing

    private var autoDosingSection: some View {
        Section {
            Toggle("Auto Dosing", isOn: $setup.autoDosingEnabled.animation())

            if setup.autoDosingEnabled {
                HStack {
                    Text("Max per dose")
                    Spacer()
                    TextField(
                        "ml",
                        value: $setup.maxDosingMl,
                        format: .number.precision(.fractionLength(2))
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    Text("ml")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Auto Dosing")
        } footer: {
            if setup.autoDosingEnabled {
                Text("Automatically doses compensatory chemicals up to the max amount per dosing event.")
            } else {
                Text("When enabled, the system will automatically dose compensatory chemicals.")
            }
        }
    }
}

#if DEBUG
#Preview {
    DosingSetupView(setup: DosingSetup()) { _ in }
}
#endif
