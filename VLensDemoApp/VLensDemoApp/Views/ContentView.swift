import SwiftUI
import UIKit
import VLensLib

struct ContentView: View {

    // MARK: - Environment
    @State private var selectedEnvIndex = 1  // Production by default — passport OCR only exists on prod
    private var currentEnv: (name: String, baseUrl: String, apiKey: String) { LoginService.envs[selectedEnvIndex] }

    // MARK: - Session
    @State private var transactionId = UUID().uuidString
    @State private var accessToken = ""
    @State private var tokenStatus: TokenStatus = .idle
    @State private var isLoggingIn = false

    // MARK: - SDK Options
    @State private var enableSounds = true
    @State private var allowAutoCapture = true
    @State private var showIdReviewPage = true

    // MARK: - Presentation
    @State private var showVLens = false
    @State private var isPassport = false
    @State private var passportDocumentNumber = ""
    @State private var passportDateOfBirth = ""
    @State private var passportExpiryDate = ""
    @State private var alertMessage: String?
    @State private var showAlert = false

    private let primary   = Color(red: 0.224, green: 0.451, blue: 0.455)  // #397374
    private let passport  = Color(red: 0.306, green: 0.353, blue: 0.471)  // #4E5A78
    private let emulator  = Color(red: 0.522, green: 0.353, blue: 0.024)  // #856404

    enum TokenStatus { case idle, loading, success, error }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                VStack(spacing: 4) {
                    Image("vlens_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 52)
                    Text("VLens iOS SDK Demo")
                        .font(.title2.bold())
                        .foregroundColor(primary)
                    Text("Configure and launch document verification")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                // Environment switcher
                sectionLabel("Environment")
                HStack(spacing: 8) {
                    ForEach(LoginService.envs.indices, id: \.self) { i in
                        let env = LoginService.envs[i]
                        Button {
                            selectedEnvIndex = i
                            performLogin()
                        } label: {
                            VStack(spacing: 2) {
                                Text(env.name)
                                    .font(.system(size: 14, weight: .bold))
                                Text(env.baseUrl.replacingOccurrences(of: "https://", with: ""))
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(selectedEnvIndex == i ? .white : Color(.label))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedEnvIndex == i ? primary : Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedEnvIndex == i ? primary : Color(.separator), lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.bottom, 16)

                // Token status banner
                HStack {
                    if isLoggingIn {
                        ProgressView().tint(primary)
                        Text("Fetching access token...")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        Text(statusText)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if !isLoggingIn {
                        Button("Refresh") { performLogin() }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(primary)
                            .cornerRadius(6)
                    }
                }
                .padding(12)
                .background(statusBannerColor)
                .cornerRadius(8)
                .padding(.bottom, 16)

                // Transaction ID
                HStack {
                    sectionLabel("Transaction ID")
                    Spacer()
                    Button("Generate New") {
                        transactionId = UUID().uuidString
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.337, green: 0.337, blue: 0.839))
                    .cornerRadius(6)
                }
                fieldBox(transactionId, lines: 1)
                    .padding(.bottom, 16)

                // SDK Configuration
                VStack(alignment: .leading, spacing: 0) {
                    Text("SDK Configuration")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.bottom, 12)

                    toggleRow(icon: "speaker.wave.2.fill", label: "Enable Sounds",
                              description: "Play audio feedback during verification",
                              value: $enableSounds)
                    Divider()
                    toggleRow(icon: "camera.viewfinder", label: "Auto Capture",
                              description: "Automatically capture when document is detected",
                              value: $allowAutoCapture)
                    Divider()
                    toggleRow(icon: "doc.text.magnifyingglass", label: "Show ID Review Page",
                              description: "Review captured ID data before proceeding",
                              value: $showIdReviewPage)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
                .padding(.bottom, 24)

                // Action buttons
                actionButton("Open Vlens SDK", color: primary, disabled: accessToken.isEmpty) {
                    startFlow(passport: false, emulator: false)
                }

                actionButton("Open Passport Flow", color: passport, disabled: accessToken.isEmpty) {
                    startFlow(passport: true, emulator: false)
                }
                .padding(.top, 12)

                // NFC emulator button
                Button {
                    startFlow(passport: true, emulator: true)
                } label: {
                    VStack(spacing: 4) {
                        Text("NFC Emulator Test")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Skips OCR → L898902C3 / 740812 / 120415")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1, green: 0.953, blue: 0.804))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(emulator)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 1, green: 0.757, blue: 0.027), lineWidth: 1)
                    )
                }
                .padding(.top, 12)
                .disabled(accessToken.isEmpty)
                .opacity(accessToken.isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { performLogin() }
        .vlensVerification(
            isPresented: $showVLens,
            transactionId: transactionId,
            apiKey: currentEnv.apiKey,
            secretKey: "",
            tenancyName: LoginService.tenancyName,
            apiBaseUrl: currentEnv.baseUrl,
            withPassport: isPassport,
            passportDocumentNumber: passportDocumentNumber,
            passportDateOfBirth: passportDateOfBirth,
            passportExpiryDate: passportExpiryDate,
            accessToken: accessToken,
            allowAutoCapture: allowAutoCapture,
            enableSounds: enableSounds,
            showIdReviewPage: showIdReviewPage,
            onSuccess: { txnId, userData in
                showVLens = false
                if isPassport {
                    alertMessage = "Passport verified!\nTransaction: \(txnId)"
                } else {
                    alertMessage = "Verified!\nName: \(userData?.user?.fullName ?? userData?.idFrontData?.name ?? "N/A")"
                }
                showAlert = true
            },
            onFailure: { txnId, error in
                showVLens = false
                alertMessage = "Failed: \(error)"
                showAlert = true
            }
        )
        .alert("VLens Result", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    // MARK: - Computed

    private var statusColor: Color {
        switch tokenStatus {
        case .success: return .green
        case .error:   return .red
        default:       return .gray
        }
    }

    private var statusBannerColor: Color {
        switch tokenStatus {
        case .success: return Color(red: 0.902, green: 0.957, blue: 0.914)
        case .error:   return Color(red: 0.992, green: 0.910, blue: 0.910)
        default:       return Color(.secondarySystemBackground)
        }
    }

    private var statusText: String {
        switch tokenStatus {
        case .success: return "Token fetched successfully"
        case .error:   return "Login failed — token may be expired"
        default:       return "Token not fetched yet"
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.primary)
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func fieldBox(_ text: String, lines: Int) -> some View {
        Text(text.isEmpty ? " " : text)
            .font(.system(size: 13))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, minHeight: CGFloat(lines * 22), alignment: .topLeading)
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator), lineWidth: 0.5))
    }

    @ViewBuilder
    private func toggleRow(icon: String, label: String, description: String, value: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Label(label, systemImage: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: value)
                .tint(primary)
                .labelsHidden()
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func actionButton(_ title: String, color: Color, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(disabled ? Color(.systemGray3) : color)
                .cornerRadius(8)
        }
        .disabled(disabled)
    }

    // MARK: - Actions

    private func performLogin() {
        isLoggingIn = true
        tokenStatus = .loading
        Task {
            do {
                let token = try await LoginService.login(baseUrl: currentEnv.baseUrl, apiKey: currentEnv.apiKey)
                accessToken = token
                tokenStatus = .success
            } catch {
                tokenStatus = .error
            }
            isLoggingIn = false
        }
    }

    private func startFlow(passport: Bool, emulator: Bool) {
        transactionId = UUID().uuidString
        isPassport = passport

        if emulator {
            // Pre-fill hardcoded emulator passport data — skips the OCR step
            passportDocumentNumber = "L898902C3"
            passportDateOfBirth    = "740812"
            passportExpiryDate     = "120415"
        } else {
            passportDocumentNumber = ""
            passportDateOfBirth    = ""
            passportExpiryDate     = ""
        }

        showVLens = true
    }

}

#Preview {
    ContentView()
}
