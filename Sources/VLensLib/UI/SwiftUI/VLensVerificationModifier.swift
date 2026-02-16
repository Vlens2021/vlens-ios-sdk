//
//  VLensVerificationModifier.swift
//  VLensLib
//
//  SwiftUI integration layer for VLens SDK.
//

import SwiftUI

// MARK: - SwiftUI View Modifier

/// A SwiftUI view modifier that presents the VLens verification flow as a full-screen cover.
@MainActor
struct VLensVerificationModifier: ViewModifier {

    @Binding var isPresented: Bool
    let transactionId: String
    let apiKey: String
    let secretKey: String
    let tenancyName: String
    let language: String
    let withLivenessOnly: Bool
    let accessToken: String
    let noOfRetries: Int
    let allowAutoCapture: Bool
    let onSuccess: (String, VerifyIdBackPost.DataClass?) -> Void
    let onFailure: (String, String) -> Void

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                VLensVerificationView(
                    transactionId: transactionId,
                    apiKey: apiKey,
                    secretKey: secretKey,
                    tenancyName: tenancyName,
                    language: language,
                    withLivenessOnly: withLivenessOnly,
                    accessToken: accessToken,
                    noOfRetries: noOfRetries,
                    allowAutoCapture: allowAutoCapture,
                    onSuccess: { txnId, userData in
                        isPresented = false
                        onSuccess(txnId, userData)
                    },
                    onFailure: { txnId, error in
                        isPresented = false
                        onFailure(txnId, error)
                    }
                )
                .ignoresSafeArea()
            }
    }
}

// MARK: - UIViewControllerRepresentable Bridge

/// Wraps `ValidationMainViewController` (UIKit) for use in SwiftUI.
///
/// The `ValidationMainViewController` calls `self.dismiss(animated:completion:)` when
/// the verification flow finishes. When hosted inside a SwiftUI `fullScreenCover`, that
/// dismiss call bubbles up to the SwiftUI hosting controller and closes the cover.
/// The delegate callbacks fire in the dismiss completion block, which then sets
/// `isPresented = false` — SwiftUI sees the cover is already gone and stays consistent.
///
/// We wrap the validation VC in a container so we can intercept its dismiss, fire the
/// delegate callbacks immediately, and let SwiftUI handle the actual dismissal via state.
struct VLensVerificationView: UIViewControllerRepresentable {

    let transactionId: String
    let apiKey: String
    let secretKey: String
    let tenancyName: String
    let language: String
    let withLivenessOnly: Bool
    let accessToken: String
    let noOfRetries: Int
    let allowAutoCapture: Bool
    let onSuccess: @MainActor @Sendable (String, VerifyIdBackPost.DataClass?) -> Void
    let onFailure: @MainActor @Sendable (String, String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess, onFailure: onFailure)
    }

    func makeUIViewController(context: Context) -> VLensContainerViewController {
        // Reset cached API responses to avoid stale data between sessions
        CachedData.shared.didGetVerifyFrontResponseSuccessfully = nil
        CachedData.shared.verifyFrontResponse   = nil
        CachedData.shared.verifyBackResponse    = nil
        CachedData.shared.livenessResponse      = nil

        // Configure VLens cached data for this session
        CachedData.shared.transactionId     = transactionId
        CachedData.shared.apiKey            = apiKey
        CachedData.shared.secretKey         = secretKey
        CachedData.shared.tenancyName       = tenancyName
        CachedData.shared.language          = language
        CachedData.shared.accessToken       = accessToken
        CachedData.shared.noOfRetries       = noOfRetries
        CachedData.shared.allowAutoCapture  = allowAutoCapture

        let validationVC = ValidationMainViewController.instance(withLivenessOnly: withLivenessOnly)
        validationVC.delegate = context.coordinator

        let container = VLensContainerViewController(child: validationVC)
        return container
    }

    func updateUIViewController(_ uiViewController: VLensContainerViewController, context: Context) {
        // No dynamic updates needed
    }

    // MARK: - Coordinator (VLensDelegate)

    class Coordinator: NSObject, VLensDelegate, @unchecked Sendable {
        let onSuccess: @MainActor @Sendable (String, VerifyIdBackPost.DataClass?) -> Void
        let onFailure: @MainActor @Sendable (String, String) -> Void

        init(onSuccess: @escaping @MainActor @Sendable (String, VerifyIdBackPost.DataClass?) -> Void,
             onFailure: @escaping @MainActor @Sendable (String, String) -> Void) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
        }

        nonisolated func didValidateSuccessfully(transactionId: String, userData: VerifyIdBackPost.DataClass?) {
            let callback = onSuccess
            Task { @MainActor in
                callback(transactionId, userData)
            }
        }

        nonisolated func didFailToValidate(transactionId: String, error: String) {
            let callback = onFailure
            Task { @MainActor in
                callback(transactionId, error)
            }
        }
    }
}

// MARK: - Container ViewController

/// A thin container that embeds `ValidationMainViewController` as a child.
/// This gives proper UIKit containment so the child's `dismiss` call works naturally.
class VLensContainerViewController: UIViewController {

    private let child: UIViewController

    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        addChild(child)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}

// MARK: - Public View Extension

public extension View {

    /// Presents the VLens verification flow as a full-screen cover.
    ///
    /// This is the recommended way to use VLens in a SwiftUI app. It wraps the UIKit-based
    /// SDK and manages presentation/dismissal through SwiftUI state.
    ///
    /// **Parameters mirror `VLensManager`'s initializer** so every SDK capability is available:
    /// - `isPresented`: Binding that controls presentation.
    /// - `transactionId`: Unique transaction identifier.
    /// - `apiKey`: Your VLens API key.
    /// - `secretKey`: Your VLens secret key (pass `""` if using access-token auth).
    /// - `tenancyName`: Your tenancy name.
    /// - `language`: UI language (`"en"` or `"ar"`). Default `"en"`.
    /// - `withLivenessOnly`: Skip ID capture and run liveness only. Default `false`.
    /// - `accessToken`: Bearer token obtained from the login API.
    /// - `noOfRetries`: Number of retry attempts on failure. Default `5`.
    /// - `allowAutoCapture`: Enable automatic document capture. Default `true`.
    /// - `onSuccess`: Called with `(transactionId, userData)` on successful verification.
    /// - `onFailure`: Called with `(transactionId, errorMessage)` on failure or cancellation.
    ///
    /// Usage:
    /// ```swift
    /// .vlensVerification(
    ///     isPresented: $showVLens,
    ///     transactionId: txnId,
    ///     apiKey: "...",
    ///     secretKey: "",
    ///     tenancyName: "...",
    ///     accessToken: token,
    ///     onSuccess: { txnId, userData in print(userData) },
    ///     onFailure: { txnId, error in print(error) }
    /// )
    /// ```
    @MainActor
    func vlensVerification(
        isPresented: Binding<Bool>,
        transactionId: String,
        apiKey: String,
        secretKey: String,
        tenancyName: String,
        language: String = "en",
        withLivenessOnly: Bool = false,
        accessToken: String,
        noOfRetries: Int = 5,
        allowAutoCapture: Bool = true,
        onSuccess: @escaping (String, VerifyIdBackPost.DataClass?) -> Void,
        onFailure: @escaping (String, String) -> Void
    ) -> some View {
        self.modifier(
            VLensVerificationModifier(
                isPresented: isPresented,
                transactionId: transactionId,
                apiKey: apiKey,
                secretKey: secretKey,
                tenancyName: tenancyName,
                language: language,
                withLivenessOnly: withLivenessOnly,
                accessToken: accessToken,
                noOfRetries: noOfRetries,
                allowAutoCapture: allowAutoCapture,
                onSuccess: onSuccess,
                onFailure: onFailure
            )
        )
    }
}
