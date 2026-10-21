import SwiftUI

struct LicenseActivationView: View {
    @ObservedObject var manager: LicenseManager
    @State private var key = ""
    @FocusState private var keyFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                ZeeBackdrop()
                    .ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: 48)

                            // Logo / Brand
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.accent.opacity(0.14))
                                        .frame(width: 80, height: 80)
                                    Image(systemName: "bolt.shield.fill")
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [AppTheme.accent, AppTheme.accentCyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                .shadow(color: AppTheme.accent.opacity(0.35), radius: 20)

                                (Text("Zee").foregroundColor(.white) + Text("OS").foregroundColor(AppTheme.accent))
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .tracking(1.2)

                                Text("Version: 1.1.0")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.45))

                                Text("PATCH CONTROL CENTER")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .tracking(2.0)
                                    .foregroundStyle(AppTheme.accentCyan.opacity(0.8))
                                    .padding(.top, 2)
                            }
                            .padding(.bottom, 30)

                            // Activation Card
                            VStack(spacing: 18) {
                                HStack(spacing: 10) {
                                    Image(systemName: manager.isBusy ? "arrow.triangle.2.circlepath" : "key.fill")
                                        .foregroundStyle(AppTheme.accentCyan)
                                        .font(.system(size: 16, weight: .bold))
                                    Text(manager.isBusy ? "Package initializing" : "License Required")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }

                                Text("Enter your ZeeOS license key to continue")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.60))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Key field
                                TextField("License key", text: $key)
                                    .focused($keyFocused)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .submitLabel(.done)
                                    .onSubmit { activate() }
                                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .frame(height: 54)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color.white.opacity(0.06))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(AppTheme.accent.opacity(keyFocused ? 0.75 : 0.35), lineWidth: 1)
                                            )
                                    )
                                    .id("license-field")

                                Toggle("Remember key on this device", isOn: $manager.rememberKey)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.65))
                                    .tint(AppTheme.accent)

                                // Verify button
                                Button(action: activate) {
                                    HStack(spacing: 9) {
                                        if manager.isBusy {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "checkmark.shield.fill")
                                        }
                                        Text(manager.isBusy ? "VERIFYING…" : "VERIFY AND CONTINUE")
                                    }
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, minHeight: 54)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [AppTheme.accent, AppTheme.accentCyan.opacity(0.85)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .shadow(color: AppTheme.accent.opacity(0.40), radius: 14, y: 6)
                                }
                                .buttonStyle(.plain)
                                .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || manager.isBusy)
                                .opacity(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)

                                if let message = manager.message {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.red)
                                        Text(message)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundStyle(.red.opacity(0.9))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.red.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.red.opacity(0.25), lineWidth: 1))
                                }

                                if let contactOwner = manager.contactOwner,
                                   let contactURL = ownerURL(from: contactOwner) {
                                    Button("Contact Owner…") {
                                        UIApplication.shared.open(contactURL)
                                    }
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.accentCyan)
                                    .buttonStyle(.plain)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                                }
                            }
                            .padding(22)
                            .background(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(.ultraThinMaterial.opacity(0.5))
                                    .background(
                                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                                            .fill(AppTheme.pageBackground.opacity(0.55))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [AppTheme.accent.opacity(0.4), AppTheme.accentCyan.opacity(0.2)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .padding(.horizontal, 22)
                            .id("activation-card")

                            Spacer(minLength: 42)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 28)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: keyFocused) { focused in
                        guard focused else { return }
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("activation-card", anchor: .center)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func activate() {
        keyFocused = false
        manager.activate(key: key)
    }

    private func ownerURL(from value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") { return URL(string: trimmed) }
        if trimmed.hasPrefix("@") { return URL(string: "https://t.me/" + String(trimmed.dropFirst())) }
        return URL(string: "https://t.me/" + trimmed)
    }
}
