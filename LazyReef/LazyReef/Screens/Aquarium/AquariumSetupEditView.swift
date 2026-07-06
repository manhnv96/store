//
//  AquariumSetupEditView.swift
//  LazyReef
//
//  Sheet for editing aquarium setup (sump type, livestock type).
//

import SwiftUI

struct AquariumSetupEditView: View {

    let initialSump: AquariumSumpType?
    let initialLivestock: AquariumLivestockType?
    let onSave: (AquariumSumpType?, AquariumLivestockType?) -> Void

    @State private var sump: AquariumSumpType?
    @State private var livestock: AquariumLivestockType?

    @Environment(\.dismiss) private var dismiss

    init(
        initialSump: AquariumSumpType?,
        initialLivestock: AquariumLivestockType?,
        onSave: @escaping (AquariumSumpType?, AquariumLivestockType?) -> Void
    ) {
        self.initialSump = initialSump
        self.initialLivestock = initialLivestock
        self.onSave = onSave
        self._sump = State(initialValue: initialSump)
        self._livestock = State(initialValue: initialLivestock)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    sumpSection
                    livestockSection
                }
                .padding(16)
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle(Language.AquariumSetup.editTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Language.AquariumSetup.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Language.AquariumSetup.save) {
                        onSave(sump, livestock)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var sumpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Language.AquariumSetup.sumpType)
                .font(.headline)
            AquariumSetupChipRow(
                options: AquariumSumpType.allCases,
                selection: $sump
            )
        }
    }

    private var livestockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Language.AquariumSetup.livestockType)
                .font(.headline)
            AquariumSetupChipRow(
                options: AquariumLivestockType.allCases,
                selection: $livestock
            )
        }
    }
}

#if DEBUG
#Preview {
    AquariumSetupEditView(
        initialSump: .overflowSump,
        initialLivestock: .sps
    ) { _, _ in }
}
#endif
