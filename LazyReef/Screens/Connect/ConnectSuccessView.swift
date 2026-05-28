//
//  ConnectSuccessView.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import SwiftUI
import CoreBluetooth
import Lottie

protocol ConnectSuccessConfiguration {
    var lottieJsonName: String { get }
    var lottielRatio: CGFloat { get }
    var title: String { get }
    var description: String { get }
}

extension ConnectSuccessConfiguration {
    var lottieJsonName: String { "Fireworks" }
    var lottielRatio: CGFloat { 446 / 251 }
}

/// Displays the list of currently connected BLE peripherals
/// and lets the user disconnect any of them.
struct ConnectSuccessView: View {
    var configuration: any ConnectSuccessConfiguration
    @Environment(\.dismiss) private var dismiss
    @Environment(\.triggerHomeRefresh) private var triggerHomeRefresh

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            lottieView
            contentView
            Spacer()
            actionView
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Sub-views

    private var lottieView: some View {
        LottieView(animation: .named(configuration.lottieJsonName))
            .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .loop)))
            .resizable()
            .aspectRatio(configuration.lottielRatio, contentMode: .fit)
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(configuration.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(configuration.description)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var actionView: some View {
        VStack(alignment: .center, spacing: 16) {
            ComponentButton(title: "Xem thiết bị", action: {
                triggerHomeRefresh()
                dismiss()
            })
                .style(.primary)
                .fillWidth()
            ComponentButton(title: "Để sau", action: {
                triggerHomeRefresh()
                dismiss()
            })
                .style(.secondary)
                .fillWidth()
        }
    }
}

#Preview {
    @Previewable @State var configuration = ConnectSuccessPreview(
        title: "Kết nối thiết bị \"JEBAO EOW-05\" thành công",
        description: "Giờ bạn hãy reset thiết bị và thử lại để kiểm tra kết nối."
    )
    ConnectSuccessView(configuration: configuration)
}


fileprivate struct ConnectSuccessPreview: ConnectSuccessConfiguration {
    let title: String
    let description: String
}

struct DeviceCreationSuccessConfig: ConnectSuccessConfiguration {
    let deviceName: String
    let connectionType: ConnectionType

    var title: String {
        "Kết nối thiết bị \"\(deviceName)\" thành công"
    }

    var description: String {
        switch connectionType {
        case .bluetooth:
            "Giờ bạn hãy reset thiết bị và thử lại để kiểm tra kết nối."
        case .wifi:
            "Giờ bạn hãy kiểm tra kết nối WiFi với thiết bị."
        }
    }
}
