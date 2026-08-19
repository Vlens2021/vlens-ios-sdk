import SwiftUI
import UIKit
import VLensLib

struct ContentView: View {

    @State private var transactionId = ""
    @State private var accessToken = ""
    @State private var isLoading = false
    @State private var showVLens = false
    @State private var isLivenessOnly = false
    @State private var alertMessage: String?
    @State private var showAlert = false
    
    // New feature toggles
    @State private var enableSounds = true
    @State private var showIdReviewPage = true
    @State private var useCustomLogo = false

    private let primary = Color(red: 0.224, green: 0.451, blue: 0.455)
    private let labelColor = Color(red: 0.125, green: 0.251, blue: 0.380)
    private let borderColor = Color(red: 0.608, green: 0.600, blue: 0.600)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Image("vlens_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                    Spacer()
                }
                .padding(.top, 20)

                Text("VLens iOS SDK Demo")
                    .font(.title2.bold())
                    .foregroundColor(primary)
                    .frame(maxWidth: .infinity)

                // Transaction ID
                Text("Transaction ID")
                    .foregroundColor(labelColor)
                fieldView(text: transactionId, lines: 1)

                // Access Token
                Text("Access Token")
                    .foregroundColor(labelColor)
                fieldView(text: accessToken, lines: 9)

                Spacer().frame(height: 16)

                // Feature Toggles Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("SDK Options")
                        .font(.headline)
                        .foregroundColor(primary)
                    
                    Toggle(isOn: $enableSounds) {
                        HStack {
                            Image(systemName: enableSounds ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .foregroundColor(primary)
                            Text("Enable Sounds")
                                .foregroundColor(labelColor)
                        }
                    }
                    .tint(primary)
                    
                    Toggle(isOn: $showIdReviewPage) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundColor(primary)
                            Text("Show ID Review Page")
                                .foregroundColor(labelColor)
                        }
                    }
                    .tint(primary)
                    
                    Toggle(isOn: $useCustomLogo) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(primary)
                            Text("Use Custom Logo (Arsenal)")
                                .foregroundColor(labelColor)
                        }
                    }
                    .tint(primary)
                    
                    if useCustomLogo {
                        HStack {
                            Spacer()
                            if let logo = UIImage(named: "arsenal_logo") {
                                Image(uiImage: logo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                            } else {
                                Text("⚠️ Add arsenal_logo to Assets")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                
                Spacer().frame(height: 16)

                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(primary)
                        Spacer()
                    }
                } else {
                    button("Set Default Data") { setDefaultData() }
                }

                button("Get Started") { startVLens(livenessOnly: false) }
                    .disabled(accessToken.isEmpty)
                    .opacity(accessToken.isEmpty ? 0.5 : 1)

                button("Get Started With Liveness Only") { startVLens(livenessOnly: true) }
                    .disabled(accessToken.isEmpty)
                    .opacity(accessToken.isEmpty ? 0.5 : 1)

            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .vlensVerification(
            isPresented: $showVLens,
            transactionId: transactionId,
            apiKey: LoginService.apiKey,
            secretKey: "",
            tenancyName: LoginService.tenancyName,
            language: "en",
            withLivenessOnly: isLivenessOnly,
            accessToken: accessToken,
            enableSounds: enableSounds,
            clientLogoImage: useCustomLogo ? UIImage(named: "arsenal_logo") : nil,
            showIdReviewPage: showIdReviewPage,
            onSuccess: { txnId, userData in
                showVLens = false
                alertMessage = "Verification successful!\nName: \(userData?.user?.fullName ?? userData?.idFrontData?.name ?? "N/A")"
                showAlert = true
            },
            onFailure: { txnId, error in
                showVLens = false
                alertMessage = "Verification failed: \(error)"
                showAlert = true
            }
        )
        .alert("VLens Result", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func fieldView(text: String, lines: Int) -> some View {
        Text(text.isEmpty ? " " : text)
            .font(.system(size: 14))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, minHeight: CGFloat(lines * 20), alignment: .topLeading)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: 0.5)
            )
    }

    @ViewBuilder
    private func button(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(primary)
                .cornerRadius(10)
        }
    }

    // MARK: - Actions

    private func setDefaultData() {
        isLoading = true
        Task {
            do {
                let token = try await LoginService.login()
                transactionId = UUID().uuidString.lowercased()
                accessToken = token
            } catch {
                alertMessage = "Login failed: \(error.localizedDescription)"
                showAlert = true
            }
            isLoading = false
        }
    }

    private func startVLens(livenessOnly: Bool) {
        isLivenessOnly = livenessOnly
        showVLens = true
    }

}

#Preview {
    ContentView()
}
