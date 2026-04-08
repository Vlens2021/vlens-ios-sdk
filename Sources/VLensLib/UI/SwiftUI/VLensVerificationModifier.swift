//
//  VLensVerificationModifier.swift
//  VLensLib
//
//  SwiftUI integration layer for VLens SDK.
//

import SwiftUI
import UIKit

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
    let allowNonTrueDepthFallback: Bool
    let showCloseButton: Bool
    let colors: VLensColors
    let enableSounds: Bool
    let clientLogoImage: UIImage?
    let showIdReviewPage: Bool
    let onSuccess: (String, VerifyIdBackPost.DataClass?) -> Void
    let onFailure: (String, String) -> Void
    let onDismiss: (() -> Void)?

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
                    allowNonTrueDepthFallback: allowNonTrueDepthFallback,
                    showCloseButton: showCloseButton,
                    colors: colors,
                    enableSounds: enableSounds,
                    clientLogoImage: clientLogoImage,
                    showIdReviewPage: showIdReviewPage,
                    onSuccess: { txnId, userData in
                        isPresented = false
                        onSuccess(txnId, userData)
                    },
                    onFailure: { txnId, error in
                        isPresented = false
                        onFailure(txnId, error)
                    },
                    onDismiss: {
                        isPresented = false
                        onDismiss?()
                    }
                )
                .ignoresSafeArea()
            }
    }
}

// MARK: - UIViewControllerRepresentable Bridge

/// A SwiftUI view that wraps `ValidationMainViewController` (UIKit) for use in SwiftUI.
///
/// This view is **public** and can be used directly for flexible presentation scenarios
/// such as `.sheet`, `NavigationStack`, or custom modal presentations.
///
/// The `ValidationMainViewController` calls `self.dismiss(animated:completion:)` when
/// the verification flow finishes. When hosted inside a SwiftUI presentation, that
/// dismiss call bubbles up to the SwiftUI hosting controller and closes the presentation.
/// The delegate callbacks fire in the dismiss completion block.
///
/// **Parameters:**
/// - `transactionId`: Unique transaction identifier.
/// - `apiKey`: Your VLens API key.
/// - `secretKey`: Your VLens secret key (pass `""` if using access-token auth).
/// - `tenancyName`: Your tenancy name.
/// - `language`: UI language (`"en"` or `"ar"`). Default `"en"`.
/// - `withLivenessOnly`: Skip ID capture and run liveness only. Default `false`.
/// - `accessToken`: Bearer token obtained from the login API.
/// - `noOfRetries`: Number of retry attempts on failure. Default `5`.
/// - `allowAutoCapture`: Enable automatic document capture. Default `true`.
/// - `showCloseButton`: Show an "X" close button in the top-right corner. Default `true`.
/// - `onSuccess`: Called with `(transactionId, userData)` on successful verification.
/// - `onFailure`: Called with `(transactionId, errorMessage)` on failure.
/// - `onDismiss`: Called when user taps the close button to dismiss. Use this for `.sheet` or custom presentations.
///
/// **Usage with .sheet:**
/// ```swift
/// .sheet(isPresented: $showVLens) {
///     VLensVerificationView(
///         transactionId: txnId,
///         apiKey: "...",
///         secretKey: "",
///         tenancyName: "...",
///         accessToken: token,
///         showCloseButton: true,
///         onSuccess: { txnId, userData in ... },
///         onFailure: { txnId, error in ... },
///         onDismiss: { showVLens = false }
///     )
/// }
/// ```
///
/// **Usage in NavigationStack:**
/// ```swift
/// NavigationStack {
///     VLensVerificationView(
///         transactionId: txnId,
///         apiKey: "...",
///         secretKey: "",
///         tenancyName: "...",
///         accessToken: token,
///         showCloseButton: false, // Use navigation bar instead
///         onSuccess: { txnId, userData in ... },
///         onFailure: { txnId, error in ... },
///         onDismiss: { path.removeLast() }
///     )
///     .navigationBarBackButtonHidden(true)
///     .toolbar {
///         ToolbarItem(placement: .navigationBarLeading) {
///             Button("Cancel") { path.removeLast() }
///         }
///     }
/// }
/// ```
public struct VLensVerificationView: UIViewControllerRepresentable {

    public let transactionId: String
    public let apiKey: String
    public let secretKey: String
    public let tenancyName: String
    public let language: String
    public let withLivenessOnly: Bool
    public let accessToken: String
    public let noOfRetries: Int
    public let allowAutoCapture: Bool
    public let allowNonTrueDepthFallback: Bool
    public let showCloseButton: Bool
    public let colors: VLensColors
    public let enableSounds: Bool
    public let clientLogoImage: UIImage?
    public let showIdReviewPage: Bool
    let onSuccess: @MainActor @Sendable (String, VerifyIdBackPost.DataClass?) -> Void
    let onFailure: @MainActor @Sendable (String, String) -> Void
    let onDismiss: (@MainActor @Sendable () -> Void)?
    
    /// Creates a VLensVerificationView for flexible presentation in SwiftUI.
    ///
    /// - Parameters:
    ///   - transactionId: Unique transaction identifier.
    ///   - apiKey: Your VLens API key.
    ///   - secretKey: Your VLens secret key (pass `""` if using access-token auth).
    ///   - tenancyName: Your tenancy name.
    ///   - language: UI language (`"en"` or `"ar"`). Default `"en"`.
    ///   - withLivenessOnly: Skip ID capture and run liveness only. Default `false`.
    ///   - accessToken: Bearer token obtained from the login API.
    ///   - noOfRetries: Number of retry attempts on failure. Default `5`.
    ///   - allowAutoCapture: Enable automatic document capture. Default `true`.
    ///   - allowNonTrueDepthFallback: Allow SDK to run on devices without TrueDepth camera (e.g., iPhone 8, SE). Default `false`.
    ///   - showCloseButton: Show an "X" close button in the top-right corner. Default `true`.
    ///   - colors: UI color configuration for branding. Default `VLensColors.default`.
    ///   - enableSounds: Enable or disable SDK sounds. Default `true`.
    ///   - clientLogoImage: Custom logo image to display in the SDK. Default `nil`.
    ///   - showIdReviewPage: Show ID review page after ID capture. Default `true`.
    ///   - onSuccess: Called with `(transactionId, userData)` on successful verification.
    ///   - onFailure: Called with `(transactionId, errorMessage)` on failure.
    ///   - onDismiss: Called when user taps the close button to dismiss.
    public init(
        transactionId: String,
        apiKey: String,
        secretKey: String,
        tenancyName: String,
        language: String = "en",
        withLivenessOnly: Bool = false,
        accessToken: String,
        noOfRetries: Int = 5,
        allowAutoCapture: Bool = true,
        allowNonTrueDepthFallback: Bool = false,
        showCloseButton: Bool = true,
        colors: VLensColors = .default,
        enableSounds: Bool = true,
        clientLogoImage: UIImage? = nil,
        showIdReviewPage: Bool = true,
        onSuccess: @escaping @MainActor @Sendable (String, VerifyIdBackPost.DataClass?) -> Void,
        onFailure: @escaping @MainActor @Sendable (String, String) -> Void,
        onDismiss: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.transactionId = transactionId
        self.apiKey = apiKey
        self.secretKey = secretKey
        self.tenancyName = tenancyName
        self.language = language
        self.withLivenessOnly = withLivenessOnly
        self.accessToken = accessToken
        self.noOfRetries = noOfRetries
        self.allowAutoCapture = allowAutoCapture
        self.allowNonTrueDepthFallback = allowNonTrueDepthFallback
        self.showCloseButton = showCloseButton
        self.colors = colors
        self.enableSounds = enableSounds
        self.clientLogoImage = clientLogoImage
        self.showIdReviewPage = showIdReviewPage
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.onDismiss = onDismiss
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess, onFailure: onFailure, onDismiss: onDismiss)
    }

    public func makeUIViewController(context: Context) -> VLensContainerViewController {
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
        CachedData.shared.allowNonTrueDepthFallback = allowNonTrueDepthFallback
        CachedData.shared.colors            = colors
        CachedData.shared.enableSounds      = enableSounds
        CachedData.shared.clientLogoImage   = clientLogoImage
        CachedData.shared.showIdReviewPage  = showIdReviewPage

        let validationVC = ValidationMainViewController.instance(withLivenessOnly: withLivenessOnly)
        validationVC.delegate = context.coordinator
        
        let coordinator = context.coordinator
        let container = VLensContainerViewController(
            child: validationVC,
            showCloseButton: showCloseButton,
            onCloseButtonTapped: { [weak coordinator] in
                coordinator?.handleDismiss()
            }
        )
        return container
    }

    public func updateUIViewController(_ uiViewController: VLensContainerViewController, context: Context) {
        CachedData.shared.transactionId             = transactionId
        CachedData.shared.apiKey                    = apiKey
        CachedData.shared.secretKey                 = secretKey
        CachedData.shared.tenancyName               = tenancyName
        CachedData.shared.language                  = language
        CachedData.shared.accessToken               = accessToken
        CachedData.shared.noOfRetries               = noOfRetries
        CachedData.shared.allowAutoCapture          = allowAutoCapture
        CachedData.shared.allowNonTrueDepthFallback = allowNonTrueDepthFallback
        CachedData.shared.colors                    = colors
        CachedData.shared.enableSounds              = enableSounds
        CachedData.shared.clientLogoImage           = clientLogoImage
        CachedData.shared.showIdReviewPage          = showIdReviewPage
    }

    // MARK: - Coordinator (VLensDelegate)

    public class Coordinator: NSObject, VLensDelegate, @unchecked Sendable {
        let onSuccess: @MainActor @Sendable (String, VerifyIdBackPost.DataClass?) -> Void
        let onFailure: @MainActor @Sendable (String, String) -> Void
        let onDismiss: (@MainActor @Sendable () -> Void)?

        init(onSuccess: @escaping @MainActor @Sendable (String, VerifyIdBackPost.DataClass?) -> Void,
             onFailure: @escaping @MainActor @Sendable (String, String) -> Void,
             onDismiss: (@MainActor @Sendable () -> Void)? = nil) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
            self.onDismiss = onDismiss
        }

        public nonisolated func didValidateSuccessfully(transactionId: String, userData: VerifyIdBackPost.DataClass?) {
            let callback = onSuccess
            Task { @MainActor in
                callback(transactionId, userData)
            }
        }

        public nonisolated func didFailToValidate(transactionId: String, error: String) {
            let callback = onFailure
            Task { @MainActor in
                callback(transactionId, error)
            }
        }
        
        func handleDismiss() {
            guard let onDismiss = onDismiss else { return }
            Task { @MainActor in
                onDismiss()
            }
        }
    }
}

// MARK: - Container ViewController

/// A thin container that embeds `ValidationMainViewController` as a child.
/// This gives proper UIKit containment so the child's `dismiss` call works naturally.
/// Optionally displays a close button for user-initiated dismissal.
public class VLensContainerViewController: UIViewController {

    private let child: UIViewController
    private let showCloseButton: Bool
    private let onCloseButtonTapped: (() -> Void)?
    private var closeButton: UIButton?

    init(child: UIViewController, showCloseButton: Bool = false, onCloseButtonTapped: (() -> Void)? = nil) {
        self.child = child
        self.showCloseButton = showCloseButton
        self.onCloseButtonTapped = onCloseButtonTapped
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let colors = CachedData.shared.colors.current(for: traitCollection)
        view.backgroundColor = colors.backgroundColor

        addChild(child)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        if showCloseButton {
            setupCloseButton()
        }
    }
    
    private func setupCloseButton() {
        let colors = CachedData.shared.colors.current(for: traitCollection)
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Create X icon using SF Symbols (iOS 13+) or fallback to text
        if let xmarkImage = UIImage(systemName: "xmark") {
            button.setImage(xmarkImage, for: .normal)
        } else {
            button.setTitle("✕", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        }
        
        button.tintColor = colors.primaryColor
        button.backgroundColor = colors.lightColor.withAlphaComponent(0.9)
        button.layer.cornerRadius = 18
        button.layer.shadowColor = colors.darkColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.15
        
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 36),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        closeButton = button
    }
    
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lockOrientationToPortrait()
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    public override var shouldAutorotate: Bool {
        return false
    }

    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    private func lockOrientationToPortrait() {
        if #available(iOS 16.0, *) {
            let scene = view.window?.windowScene
                ?? UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            scene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            setNeedsUpdateOfSupportedInterfaceOrientations()
        }
        // Belt-and-suspenders: works on all iOS versions and handles the SwiftUI hosting case
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

// MARK: - Public View Extension

public extension View {

    /// Presents the VLens verification flow as a full-screen cover.
    ///
    /// This is the recommended way to use VLens in a SwiftUI app when you want full-screen presentation.
    /// For more flexibility (e.g., `.sheet`, `NavigationStack`), use `VLensVerificationView` directly.
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
    /// - `allowNonTrueDepthFallback`: Allow SDK on devices without TrueDepth camera (falls back to auto-capture). Default `false`.
    /// - `showCloseButton`: Show an "X" close button. Default `false` (since fullScreenCover handles dismissal).
    /// - `colors`: UI color configuration for branding. Default `VLensColors.default`.
    /// - `onSuccess`: Called with `(transactionId, userData)` on successful verification.
    /// - `onFailure`: Called with `(transactionId, errorMessage)` on failure or cancellation.
    /// - `onDismiss`: Called when user taps the close button. Only relevant if `showCloseButton` is `true`.
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
    ///     colors: VLensColors(
    ///         light: VLensColorConfig(primary: "#1E3A5F", accent: "#007AFF"),
    ///         dark: VLensColorConfig(primary: "#FFFFFF", accent: "#0A84FF")
    ///     ),
    ///     onSuccess: { txnId, userData in print(userData) },
    ///     onFailure: { txnId, error in print(error) }
    /// )
    /// ```
    ///
    /// **For flexible presentation**, use `VLensVerificationView` directly:
    /// ```swift
    /// .sheet(isPresented: $showVLens) {
    ///     VLensVerificationView(
    ///         transactionId: txnId,
    ///         apiKey: "...",
    ///         secretKey: "",
    ///         tenancyName: "...",
    ///         accessToken: token,
    ///         showCloseButton: true,
    ///         onSuccess: { ... },
    ///         onFailure: { ... },
    ///         onDismiss: { showVLens = false }
    ///     )
    /// }
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
        allowNonTrueDepthFallback: Bool = false,
        showCloseButton: Bool = false,
        colors: VLensColors = .default,
        enableSounds: Bool = true,
        clientLogoImage: UIImage? = nil,
        showIdReviewPage: Bool = true,
        onSuccess: @escaping (String, VerifyIdBackPost.DataClass?) -> Void,
        onFailure: @escaping (String, String) -> Void,
        onDismiss: (() -> Void)? = nil
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
                allowNonTrueDepthFallback: allowNonTrueDepthFallback,
                showCloseButton: showCloseButton,
                colors: colors,
                enableSounds: enableSounds,
                clientLogoImage: clientLogoImage,
                showIdReviewPage: showIdReviewPage,
                onSuccess: onSuccess,
                onFailure: onFailure,
                onDismiss: onDismiss
            )
        )
    }
}
