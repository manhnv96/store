//
//  AquariumDetailView.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import SwiftUI

struct AquariumDetailView: View {

    @State var viewModel: AquariumDetailViewModel
    @State private var deviceToRemove: ConnectedDevice?
    @State private var showingLogForm = false
    @State private var showingVoiceLog = false
    @State private var editingLog: WaterReading?
    @State private var logToDelete: WaterReading?
    @State private var wake = WakeWordListener()
    @State private var lastWakeReading: ParsedReading?
    @State private var toastVisible = false
    @State private var toastDismissTask: Task<Void, Never>?
    /// True once the user explicitly turned wake mode off via the ear button
    /// or banner Stop. Prevents auto-resume after dismissing a sheet.
    @State private var userDisabledWake = false
    @State private var showingSetupEdit = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                contentView
            }
        }
        .overlay(alignment: .top) {
            VStack(spacing: 8) {
                if wake.isActive {
                    wakeBanner
                }
                if toastVisible, let r = lastWakeReading {
                    savedToast(reading: r)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .animation(.easeInOut(duration: 0.25), value: wake.isActive)
            .animation(.easeInOut(duration: 0.25), value: toastVisible)
        }
        .onDisappear {
            wake.stop()
            toastDismissTask?.cancel()
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(viewModel.aquarium.name)
                    .font(.title3.weight(.medium))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSetupEdit = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                }
            }
        }
        .navigationDestination(for: WaterDashboardDestination.self) { dest in
            WaterDashboardView(
                viewModel: WaterDashboardViewModel(
                    aquarium: viewModel.aquarium,
                    initialSelection: dest.focusedParameter
                )
            )
        }
        .alert(
            Language.AquariumDetail.removeConfirmTitle,
            isPresented: Binding(
                get: { deviceToRemove != nil },
                set: { if !$0 { deviceToRemove = nil } }
            ),
            presenting: deviceToRemove
        ) { device in
            Button(Language.DeviceAction.cancel, role: .cancel) {
                deviceToRemove = nil
            }
            Button(Language.AquariumDetail.removeAction, role: .destructive) {
                Task {
                    await viewModel.removeFromAquarium(device)
                    deviceToRemove = nil
                }
            }
        } message: { _ in
            Text(Language.AquariumDetail.removeConfirmMessage)
        }
        .alert(
            Language.Log.deleteConfirmTitle,
            isPresented: Binding(
                get: { logToDelete != nil },
                set: { if !$0 { logToDelete = nil } }
            ),
            presenting: logToDelete
        ) { log in
            Button(Language.Log.cancel, role: .cancel) { logToDelete = nil }
            Button(Language.Log.delete, role: .destructive) {
                Task {
                    await viewModel.deleteLog(log.id)
                    logToDelete = nil
                }
            }
        } message: { _ in
            Text(Language.Log.deleteConfirmMessage)
        }
        .sheet(isPresented: $showingLogForm, onDismiss: { editingLog = nil }) {
            LogEntryFormView(
                aquariumID: viewModel.aquarium.id,
                editing: editingLog
            ) { reading, isEdit in
                Task {
                    if isEdit {
                        await viewModel.update(reading)
                    } else {
                        await viewModel.save(reading)
                    }
                }
            }
        }
        .sheet(isPresented: $showingVoiceLog) {
            VoiceLogSheet(
                aquariumID: viewModel.aquarium.id,
                aquariumName: viewModel.aquarium.name
            ) { reading in
                Task { await viewModel.save(reading) }
            }
        }
        .sheet(isPresented: $showingSetupEdit) {
            AquariumSetupEditView(
                initialSump: viewModel.aquarium.sumpType,
                initialLivestock: viewModel.aquarium.livestockType
            ) { sump, livestock in
                Task {
                    await viewModel.updateSettings(
                        sumpType: sump,
                        livestockType: livestock
                    )
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .task {
            await startWakeIfNeeded()
        }
        .onChange(of: showingLogForm) { _, isShowing in
            handleSheetPresentationChange(isShowing)
        }
        .onChange(of: showingVoiceLog) { _, isShowing in
            handleSheetPresentationChange(isShowing)
        }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                waterSection
                devicesSection
                logsSection
            }
            .padding(16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Water

    private var waterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Language.AquariumDetail.waterSectionTitle)
                    .font(.title3.weight(.semibold))
                Spacer()
                NavigationLink(value: WaterDashboardDestination()) {
                    HStack(spacing: 4) {
                        Text(Language.AquariumDetail.seeDetail)
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.blue)
                }
            }

            WaterParametersCompactView(summaries: viewModel.parameters)
        }
    }

    // MARK: - Devices

    private var devicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Language.AquariumDetail.devicesSection)
                    .font(.title3.weight(.semibold))
                Spacer()
                NavigationLink(
                    value: ConnectDestination(aquariumID: viewModel.aquarium.id)
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }

            if viewModel.devices.isEmpty {
                emptyDeviceList
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.devices) { device in
                        deviceRow(device)
                    }
                }
            }
        }
    }

    private var emptyDeviceList: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(Language.AquariumDetail.devicesEmpty)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            NavigationLink(
                value: ConnectDestination(aquariumID: viewModel.aquarium.id)
            ) {
                Text(Language.AquariumDetail.addDeviceAction)
                    .font(.subheadline.weight(.medium))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func deviceRow(_ device: ConnectedDevice) -> some View {
        NavigationLink(value: device) {
            HStack(spacing: 12) {
                Image(systemName: device.kind.iconSystemName)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(device.deviceName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(device.kind.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(lastActivityText(for: device))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                statusIndicator(for: device)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                deviceToRemove = device
            } label: {
                Label(
                    Language.AquariumDetail.removeAction,
                    systemImage: "minus.circle"
                )
            }
        }
    }

    // MARK: - Helpers

    private func lastActivityText(for device: ConnectedDevice) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let relative = formatter.localizedString(for: device.lastUpdate, relativeTo: .now)
        return "\(Language.AquariumDetail.lastActivity): \(relative)"
    }

    private func statusIndicator(for device: ConnectedDevice) -> some View {
        let isRecent = Date().timeIntervalSince(device.lastUpdate) < 3600
        return HStack(spacing: 4) {
            Circle()
                .fill(isRecent ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text(isRecent ? Language.AquariumDetail.statusOnline : Language.AquariumDetail.statusOffline)
                .font(.caption2)
                .foregroundStyle(isRecent ? .green : .secondary)
        }
    }

    // MARK: - Logs

    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Language.Log.title)
                    .font(.title3.weight(.semibold))
                Spacer()
                Button {
                    toggleWakeMode()
                } label: {
                    Image(systemName: wake.isActive ? "ear.fill" : "ear")
                        .font(.title2)
                        .foregroundStyle(wake.isActive ? .green : .secondary)
                }
                Button {
                    showingVoiceLog = true
                } label: {
                    Image(systemName: "mic.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
                Button {
                    editingLog = nil
                    showingLogForm = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }

            if viewModel.recentLogs.isEmpty {
                emptyLogsView
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentLogs) { log in
                        logRow(log)
                    }
                }
            }
        }
    }

    private var emptyLogsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(Language.Log.empty)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Button {
                    showingVoiceLog = true
                } label: {
                    Label(Language.Log.addVoice, systemImage: "mic.fill")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1), in: Capsule())
                        .foregroundStyle(.red)
                }
                Button {
                    editingLog = nil
                    showingLogForm = true
                } label: {
                    Label(Language.Log.addManual, systemImage: "pencil")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1), in: Capsule())
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func logRow(_ log: WaterReading) -> some View {
        Button {
            editingLog = log
            showingLogForm = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: log.type.iconSystemName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(log.type.title)
                            .font(.subheadline.weight(.semibold))
                        Text(formattedValue(log))
                            .font(.subheadline.weight(.bold).monospacedDigit())
                        if !log.type.unit.isEmpty {
                            Text(log.type.unit)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack(spacing: 6) {
                        Image(systemName: log.source.iconSystemName)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text(log.timestamp.formatted(.relative(presentation: .named)))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                logToDelete = log
            } label: {
                Label(Language.Log.delete, systemImage: "trash")
            }
        }
    }

    private func formattedValue(_ log: WaterReading) -> String {
        switch log.type {
        case .ph, .temperature, .oxygen:
            return String(format: "%.1f", log.value)
        case .po4:
            return String(format: "%.2f", log.value)
        case .salinity:
            return String(format: "%.3f", log.value)
        default:
            return String(format: "%.0f", log.value)
        }
    }

    // MARK: - Wake mode

    private var wakeBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "waveform.badge.mic")
                .font(.title3)
                .foregroundStyle(.green)
                .symbolEffect(.pulse, options: .repeating, isActive: wake.isActive)
            VStack(alignment: .leading, spacing: 1) {
                Text(Language.WakeMode.listening)
                    .font(.subheadline.weight(.semibold))
                if !wake.transcription.isEmpty {
                    Text(wake.transcription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(Language.WakeMode.instruction)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Button(Language.WakeMode.stop) {
                wake.stop()
                userDisabledWake = true
            }
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.15), in: Capsule())
            .foregroundStyle(.red)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func savedToast(reading: ParsedReading) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("\(Language.WakeMode.savedToast): \(reading.parameter.title) = \(toastDisplayValue(reading))")
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
            if !reading.parameter.unit.isEmpty {
                Text(reading.parameter.unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(Language.WakeMode.undo) {
                Task {
                    if let latest = viewModel.recentLogs.first {
                        await viewModel.deleteLog(latest.id)
                    }
                    hideToast()
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.blue)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.25), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func toastDisplayValue(_ r: ParsedReading) -> String {
        switch r.parameter {
        case .ph, .temperature, .oxygen: return String(format: "%.1f", r.value)
        case .po4: return String(format: "%.2f", r.value)
        case .salinity: return String(format: "%.3f", r.value)
        default: return String(format: "%.0f", r.value)
        }
    }

    private func toggleWakeMode() {
        if wake.isActive {
            wake.stop()
            userDisabledWake = true
        } else {
            userDisabledWake = false
            Task { await startWakeIfNeeded() }
        }
    }

    /// Start the wake listener when entering the view (or after a sheet closes)
    /// — unless the user has explicitly disabled it via the ear button.
    private func startWakeIfNeeded() async {
        guard !wake.isActive, !userDisabledWake else { return }
        wake.onReadingDetected = { reading in
            Task { @MainActor in
                handleWakeReading(reading)
            }
        }
        await wake.start()
    }

    /// Pause wake mode while a sheet (manual form or voice log) is presented
    /// to free the shared audio session, then resume on dismiss.
    private func handleSheetPresentationChange(_ isShowing: Bool) {
        if isShowing {
            if wake.isActive { wake.stop() }
        } else {
            Task { await startWakeIfNeeded() }
        }
    }

    private func handleWakeReading(_ reading: ParsedReading) {
        let now = Date()
        let waterReading = WaterReading(
            aquariumID: viewModel.aquarium.id,
            type: reading.parameter,
            value: reading.value,
            timestamp: now,
            source: .voice,
            note: nil,
            createdAt: now,
            updatedAt: now
        )
        Task {
            await viewModel.save(waterReading)
        }
        lastWakeReading = reading
        toastVisible = true
        toastDismissTask?.cancel()
        toastDismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            toastVisible = false
        }
    }

    private func hideToast() {
        toastDismissTask?.cancel()
        toastVisible = false
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AquariumDetailView(
            viewModel: AquariumDetailViewModel(aquarium: Aquarium.mocks[0])
        )
    }
}
#endif
