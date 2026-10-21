import SwiftUI
import UIKit
import AVFoundation

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @State private var showSettings = false
    @State private var showCleaner = false
    @StateObject private var patchStore = PatchProjectStore()
    @State private var patchOperationBusy = false
    @State private var patchMessage = "READY — SELECT A PATCH"
    @State private var aimDragEnabled = false
    @State private var aimNeckEnabled = false
    @State private var hspeitoffEnabled = false
    @State private var hyperBalamagicaEnabled = false
    @State private var aimBodyPackageEnabled = false
    @State private var aimChestPackageEnabled = false
    @State private var magicEnabled = false

    var body: some View {
        ZStack {
            ZeeBackdrop()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    brandHeader
                    devicePanel
                    patchOptions
                    gameLaunchPanel
                    footerStatus
                    developerCredits
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showCleaner) {
            CleanerView()
        }
        .sheet(item: $patchStore.passwordRequest, onDismiss: patchStore.cancelUnlock) { _ in
            PatchUnlockPrompt(store: patchStore)
        }
        .onAppear { syncPatchStates() }
        .onChange(of: scenePhase) { phase in
            guard phase == .active, !patchOperationBusy else { return }
            syncPatchStates()
            patchMessage = "READY — SELECT A PATCH"
        }
    }

    // MARK: - Brand Header
    private var brandHeader: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Zee")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    + Text("OS")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.accent)

                }
                Text("PATCH CONTROL CENTER")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .tracking(2.2)
                    .foregroundColor(AppTheme.secondaryAccent.opacity(0.75))
            }

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 46, height: 46)
                    .background(
                        AppTheme.accent.opacity(0.12),
                        in: Circle()
                    )
                    .overlay(Circle().stroke(AppTheme.accent.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open settings")
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Device Panel
    private var devicePanel: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(AppTheme.accent)
                Text("DEVICE STATUS")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.6)
                    .foregroundColor(AppTheme.accent)
                Spacer()
                Circle()
                    .fill(appState.isSupported ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                    .shadow(color: appState.isSupported ? .green : .red, radius: 5)
            }
            .padding(.bottom, 14)

            VStack(spacing: 0) {
                statusRow(icon: "apple.logo",     title: "iOS",     value: AppInfo.osVersion,          color: AppTheme.accentCyan)
                Divider().background(AppTheme.accent.opacity(0.12)).padding(.vertical, 6)
                statusRow(icon: "iphone",         title: "Device",  value: AppInfo.displayMachineName,  color: AppTheme.accentCyan)
                Divider().background(AppTheme.accent.opacity(0.12)).padding(.vertical, 6)
                statusRow(icon: "checkmark.seal.fill", title: "Status",
                          value: appState.isSupported ? "SUPPORTED" : "UNSUPPORTED",
                          color: appState.isSupported ? .green : .red)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppTheme.pageBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.accent.opacity(0.5), AppTheme.accentCyan.opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    // MARK: - Patch Options
    private var patchOptions: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(AppTheme.accent)
                Text("PATCH OPTIONS")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.6)
                    .foregroundColor(AppTheme.accent)
                Spacer()
                Text("TAP TO TOGGLE")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .tracking(0.8)
                    .foregroundColor(.white.opacity(0.35))
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                patchCard(name: "Aim Drag",  target: "FREE FIRE", package: "ZeeOS File (6).3105",  color: AppTheme.accent,      state: $aimDragEnabled)
                patchCard(name: "Aim Neck",  target: "FREE FIRE", package: "ZeeOS File (7).3105",  color: AppTheme.accentCyan,  state: $aimNeckEnabled)
                patchCard(name: "Antenna",   target: "FREE FIRE", package: "ZeeOS File (8).3105",  color: AppTheme.accentCyan,  state: $hspeitoffEnabled)
                patchCard(name: "144 FPS",   target: "FREE FIRE", package: "ZeeOS File (10).3105", color: AppTheme.accent,      state: $hyperBalamagicaEnabled)
                patchCard(name: "Aim Body",  target: "FREE FIRE", package: "ZeeOS File (12).3105", color: AppTheme.accentCyan,  state: $aimBodyPackageEnabled)
                patchCard(name: "Aim Chest", target: "FREE FIRE", package: "ZeeOS File (2).3105",  color: AppTheme.accent,      state: $aimChestPackageEnabled)
                patchCard(name: "Magic",     target: "FREE FIRE", package: "ZeeOS File (14).3105", color: AppTheme.accentCyan,  state: $magicEnabled)
            }

            // Status bar
            HStack(spacing: 8) {
                if patchOperationBusy {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                        .scaleEffect(0.65)
                } else {
                    Circle()
                        .fill(patchMessage.localizedCaseInsensitiveContains("successful") ? .green : AppTheme.accent)
                        .frame(width: 6, height: 6)
                        .shadow(color: patchMessage.localizedCaseInsensitiveContains("successful") ? .green : AppTheme.accent, radius: 4)
                }
                Text(patchOperationBusy ? "PROCESSING PATCH…" : patchMessage)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(Color.black.opacity(0.38))
                    .overlay(Capsule().stroke(AppTheme.accent.opacity(0.22), lineWidth: 1))
            )
        }
    }

    private func patchCard(name: String, target: String, package: String, color: Color, state: Binding<Bool>) -> some View {
        PatchOptionCard(name: name, target: target, color: color, isEnabled: state, isBusy: patchOperationBusy) {
            togglePatch(packageFilename: package, state: state)
        }
    }

    // MARK: - Game Launch
    private var gameLaunchPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 7) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(AppTheme.accent)
                Text("LAUNCH GAME")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.6)
                    .foregroundColor(AppTheme.accent)
            }

            HStack(spacing: 12) {
                launchButton(title: "FF NORMAL", subtitle: "Free Fire Normal", color: AppTheme.accent, scheme: "freefireth")
                lockedLaunchButton(title: "FF MAX", subtitle: "Coming Soon", color: AppTheme.accentCyan)
            }

            Button {
                showCleaner = true
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: "trash.slash.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.accentCyan)
                    Text("Clean Cache & Temp")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity, minHeight: 52)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.38))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.accentCyan.opacity(0.35), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open cache and temporary files cleaner")
        }
    }

    private func launchButton(title: String, subtitle: String, color: Color, scheme: String) -> some View {
        Button { openGame(scheme: scheme) } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "arrow.up.right.square.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(color.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(color.opacity(0.45), lineWidth: 1)
                    )
            )
            .shadow(color: color.opacity(0.15), radius: 10)
        }
        .buttonStyle(.plain)
    }

    private func lockedLaunchButton(title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color.opacity(0.5))
            Text(title)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
            Text(subtitle)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(color.opacity(0.55))
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(color.opacity(0.18), lineWidth: 1)
                )
        )
        .opacity(0.65)
        .accessibilityLabel("FF MAX locked, coming soon")
    }

    // MARK: - Footer
    private var footerStatus: some View {
        HStack(spacing: 10) {
            Circle().fill(.green).frame(width: 8, height: 8).shadow(color: .green, radius: 5)
            Text("SISTEMA PRONTO")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundColor(.white.opacity(0.65))
            Spacer()
            Text("ZeeOS • READY")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.accentCyan.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule().fill(Color.black.opacity(0.40))
                .overlay(Capsule().stroke(AppTheme.accentCyan.opacity(0.2), lineWidth: 1))
        )
    }

    // MARK: - Credits
    private var developerCredits: some View {
        VStack(spacing: 10) {
            Text("Developed by ZeeOS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))

            Text("Official Channels")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.accentCyan.opacity(0.75))

            channelButton(title: "ZeeOS Telegram", url: "https://t.me/ogios1")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private func channelButton(title: String, url: String) -> some View {
        Button {
            guard let destination = URL(string: url) else { return }
            UIApplication.shared.open(destination)
        } label: {
            Label(title, systemImage: "paperplane.fill")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(AppTheme.accent.opacity(0.15), in: Capsule())
                .overlay(Capsule().stroke(AppTheme.accent.opacity(0.40), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers
    private func statusRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 22)
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.50))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
    }

    private func syncPatchStates() {
        aimDragEnabled         = isPatchActive("ZeeOS File (6).3105")
        aimNeckEnabled         = isPatchActive("ZeeOS File (7).3105")
        hspeitoffEnabled       = isPatchActive("ZeeOS File (8).3105")
        hyperBalamagicaEnabled = isPatchActive("ZeeOS File (10).3105")
        aimBodyPackageEnabled  = isPatchActive("ZeeOS File (12).3105")
        aimChestPackageEnabled = isPatchActive("ZeeOS File (2).3105")
        magicEnabled           = isPatchActive("ZeeOS File (14).3105")
    }

    private func isPatchActive(_ packageFilename: String) -> Bool {
        patchStore.items.first(where: { $0.packageURL.lastPathComponent.caseInsensitiveCompare(packageFilename) == .orderedSame })
            .flatMap { DevicePatchService.latestReceipt(projectID: $0.id) } != nil
    }

    private enum PatchActionResult {
        case applied
        case restored
        case unavailable(String)
    }

    private func setPatchState(for packageFilename: String, enabled: Bool) {
        switch packageFilename {
        case "ZeeOS File (6).3105":  aimDragEnabled         = enabled
        case "ZeeOS File (7).3105":  aimNeckEnabled         = enabled
        case "ZeeOS File (8).3105":  hspeitoffEnabled       = enabled
        case "ZeeOS File (10).3105": hyperBalamagicaEnabled = enabled
        case "ZeeOS File (12).3105": aimBodyPackageEnabled  = enabled
        case "ZeeOS File (2).3105":  aimChestPackageEnabled = enabled
        case "ZeeOS File (14).3105": magicEnabled           = enabled
        default: break
        }
    }

    private func togglePatch(packageFilename: String, state: Binding<Bool>) {
        guard !patchOperationBusy else { return }
        guard let item = patchStore.items.first(where: {
            $0.packageURL.lastPathComponent.caseInsensitiveCompare(packageFilename) == .orderedSame
        }) else {
            patchMessage = "ERROR — PACKAGE NOT FOUND"
            log("patch: package not found: \(packageFilename)")
            return
        }

        let wasEnabled = state.wrappedValue
        patchOperationBusy = true
        patchMessage = "PROCESSING — \(packageFilename)"
        let project   = item.project
        let projectID = item.id

        DispatchQueue.global(qos: .userInitiated).async {
            let result: PatchActionResult
            do {
                if wasEnabled {
                    guard let receipt = DevicePatchService.latestReceipt(projectID: projectID) else {
                        result = .unavailable("NO ACTIVE RECEIPT — NOTHING TO RESTORE")
                        DispatchQueue.main.async {
                            self.setPatchState(for: packageFilename, enabled: false)
                            self.patchMessage = "OFF — NO ACTIVE PATCH FOUND"
                            self.patchOperationBusy = false
                        }
                        return
                    }
                    try DevicePatchService.restore(receipt: receipt)
                    result = .restored
                } else {
                    guard let project else {
                        result = .unavailable("PASSWORD REQUIRED — UNLOCK PACKAGE")
                        DispatchQueue.main.async {
                            self.patchStore.requestUnlock(for: item)
                            self.patchMessage = "PASSWORD REQUIRED — ENTER PACKAGE PASSWORD"
                            self.patchOperationBusy = false
                        }
                        return
                    }
                    _ = try DevicePatchService.apply(project: project)
                    result = .applied
                }
            } catch {
                result = .unavailable("FAILED — \(String(describing: error))")
            }

            DispatchQueue.main.async {
                switch result {
                case .applied:
                    self.setPatchState(for: packageFilename, enabled: true)
                    self.patchMessage = "Inject Successful — \(packageFilename)"
                    PatchAudioFeedback.bypassActivated()
                case .restored:
                    self.setPatchState(for: packageFilename, enabled: false)
                    self.patchMessage = "Restore Successful — \(packageFilename)"
                    PatchAudioFeedback.originalRestored()
                case .unavailable(let message):
                    self.patchMessage = message
                }
                self.patchOperationBusy = false
            }
        }
    }

    private func openGame(scheme: String) {
        guard let url = URL(string: "\(scheme)://") else { return }
        UIApplication.shared.open(url, options: [:]) { success in
            log("launch: \(scheme) success=\(success)")
        }
    }
}

// MARK: - Patch Card
private struct PatchOptionCard: View {
    let name: String
    let target: String
    let color: Color
    @Binding var isEnabled: Bool
    let isBusy: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(isEnabled ? 0.20 : 0.10))
                            .frame(width: 32, height: 32)
                        Image(systemName: isEnabled ? "bolt.fill" : "bolt")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(color)
                    }
                    Spacer()
                    Text(isEnabled ? "ON" : "OFF")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(isEnabled ? .green : .white.opacity(0.45))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(isEnabled ? Color.green.opacity(0.15) : Color.white.opacity(0.07))
                        )
                }

                Text(name)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(target)
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(color.opacity(0.85))

                HStack(spacing: 6) {
                    Circle()
                        .fill(isEnabled ? Color.green : Color.white.opacity(0.22))
                        .frame(width: 6, height: 6)
                        .shadow(color: isEnabled ? .green : .clear, radius: 4)
                    Text(isEnabled ? "ACTIVE" : "INACTIVE")
                        .font(.system(size: 8, weight: .black, design: .rounded))
                        .tracking(0.7)
                        .foregroundColor(.white.opacity(0.55))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isEnabled ? color.opacity(0.08) : Color.black.opacity(0.45))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                isEnabled ? color.opacity(0.75) : color.opacity(0.22),
                                lineWidth: isEnabled ? 1.5 : 1
                            )
                    )
            )
            .shadow(color: isEnabled ? color.opacity(0.22) : .clear, radius: 14)
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
        .opacity(isBusy ? 0.55 : 1)
        .accessibilityLabel("\(name), \(target), \(isEnabled ? "On" : "Off")")
    }
}

// MARK: - Audio Feedback
private enum PatchAudioFeedback {
    private static let synthesizer = AVSpeechSynthesizer()
    static func bypassActivated() { speak("Bypass ativado") }
    static func originalRestored() { speak("Bypass desativado") }
    private static func speak(_ message: String) {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true, options: [])
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: message)
        let voices = AVSpeechSynthesisVoice.speechVoices()
        utterance.voice = voices.first(where: {
            ($0.language.hasPrefix("pt-BR") || $0.language.hasPrefix("pt-PT") || $0.language.hasPrefix("pt")) &&
            $0.gender == .female && $0.quality == .enhanced
        }) ?? voices.first(where: {
            $0.language.hasPrefix("pt-BR") || $0.language.hasPrefix("pt-PT") || $0.language.hasPrefix("pt")
        }) ?? AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = 0.43
        utterance.pitchMultiplier = 1.10
        utterance.volume = 0.90
        synthesizer.speak(utterance)
    }
}

// MARK: - Patch Unlock Prompt
private struct PatchUnlockPrompt: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: PatchProjectStore
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Package password", text: $password)
                        .textContentType(.password)
                        .submitLabel(.done)
                        .onSubmit(unlock)
                        .onChange(of: password) { _ in store.clearUnlockError() }
                    if let errorKey = store.unlockErrorKey {
                        Text(AppLanguage.english.text(errorKey))
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                } footer: {
                    Text("Enter the password once to unlock this ZeeOS package on this device.")
                }
            }
            .navigationTitle("Unlock package")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Unlock", action: unlock)
                        .disabled(password.isEmpty || store.isBusy)
                }
            }
        }
    }

    private func unlock() {
        guard !password.isEmpty else { return }
        store.unlock(password: password)
    }
}

// MARK: - ZeeOS Backdrop
struct ZeeBackdrop: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppTheme.pageBackground

                // Blue glow top
                Circle()
                    .fill(AppTheme.accent.opacity(0.18))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: animate ? 100 : -100, y: -proxy.size.height * 0.28)

                // Cyan glow bottom
                Circle()
                    .fill(AppTheme.accentCyan.opacity(0.12))
                    .frame(width: 260, height: 260)
                    .blur(radius: 90)
                    .offset(x: animate ? -90 : 90, y: proxy.size.height * 0.28)

                // Subtle grid
                ZeeGridOverlay()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
    }
}

// Keep old name as alias for LicenseActivationView which uses AnimatedHyperBackdrop
struct AnimatedHyperBackdrop: View {
    var body: some View { ZeeBackdrop() }
}

private struct ZeeGridOverlay: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let spacing: CGFloat = 42
            stride(from: CGFloat(0), through: size.width, by: spacing).forEach { x in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            stride(from: CGFloat(0), through: size.height, by: spacing).forEach { y in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(AppTheme.accent.opacity(0.045)), lineWidth: 1)
        }
    }
}
