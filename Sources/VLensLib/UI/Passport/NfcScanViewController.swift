import UIKit
internal import Alamofire

class NfcScanViewController: UIViewController {

    // MARK: - Factory

    static func instance() -> NfcScanViewController {
        NfcScanViewController()
    }

    var delegate: ValidationMainViewControllerDelegate?

    // MARK: - State

    private enum ScanState {
        case idle
        case scanning
        case verifying
        case success
        case error(String)
    }

    private var state: ScanState = .idle {
        didSet { updateUI() }
    }

    private var shareableLog: String?

    // MARK: - Reader

    private let reader = NfcPassportReader()

    // MARK: - UI elements (built programmatically — no XIB needed)

    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    // Ripple animation container
    private let rippleContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private var rippleLayers: [CAShapeLayer] = []
    private var rippleTimer: Timer?

    // Tips card
    private let tipsCard: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 0
        return v
    }()

    // Spinner
    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.hidesWhenStopped = true
        return s
    }()

    // Checkmark
    private let checkmarkLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 48, weight: .bold)
        l.text = "✓"
        l.textAlignment = .center
        return l
    }()

    // Error icon
    private let errorIconLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 40, weight: .bold)
        l.text = "!"
        l.textAlignment = .center
        return l
    }()

    private let errorDetailLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let shareLogButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Share Error Log", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        return b
    }()

    // Footer
    private let footerStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 12
        s.distribution = .fillEqually
        return s
    }()
    private let primaryButton   = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        applyColors()
        updateUI()
    }

    // MARK: - Layout

    private func buildLayout() {
        view.addSubview(scrollView)
        view.addSubview(footerStack)
        scrollView.addSubview(contentStack)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 16
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        contentStack.isLayoutMarginsRelativeArrangement = true

        NSLayoutConstraint.activate([
            footerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            footerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            footerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            footerStack.heightAnchor.constraint(equalToConstant: 50),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerStack.topAnchor, constant: -8),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // Logo
        if let logo = CachedData.shared.clientLogoImage {
            logoImageView.image = logo
        } else {
            logoImageView.isHidden = true
        }
        contentStack.addArrangedSubview(logoImageView)

        // Title
        contentStack.addArrangedSubview(titleLabel)

        // Subtitle
        contentStack.addArrangedSubview(subtitleLabel)

        // Ripple container (120×120)
        rippleContainer.heightAnchor.constraint(equalToConstant: 120).isActive = true
        rippleContainer.widthAnchor.constraint(equalToConstant: 120).isActive = true
        contentStack.addArrangedSubview(rippleContainer)

        // Tips card
        buildTipsCard()
        contentStack.addArrangedSubview(tipsCard)
        tipsCard.widthAnchor.constraint(equalTo: contentStack.widthAnchor, constant: -48).isActive = true

        // Spinner
        contentStack.addArrangedSubview(spinner)

        // Checkmark circle
        let checkCircle = makeCircle(size: 80, view: checkmarkLabel)
        contentStack.addArrangedSubview(checkCircle)

        // Error circle
        let errorCircle = makeCircle(size: 70, view: errorIconLabel)
        contentStack.addArrangedSubview(errorCircle)

        // Error detail
        contentStack.addArrangedSubview(errorDetailLabel)
        errorDetailLabel.widthAnchor.constraint(equalTo: contentStack.widthAnchor, constant: -48).isActive = true

        // Share log button
        contentStack.addArrangedSubview(shareLogButton)
        shareLogButton.addTarget(self, action: #selector(shareLog), for: .touchUpInside)

        // Footer buttons
        [secondaryButton, primaryButton].forEach { btn in
            btn.layer.cornerRadius = 8
            btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            footerStack.addArrangedSubview(btn)
        }
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
    }

    private func buildTipsCard() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        tipsCard.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: tipsCard.topAnchor),
            stack.leadingAnchor.constraint(equalTo: tipsCard.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: tipsCard.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: tipsCard.bottomAnchor),
        ])

        let title = makeLabel("Tips:", size: 14, weight: .semibold)
        stack.addArrangedSubview(title)
        [
            "1.  Open your passport to the photo page.",
            "2.  Place the phone flat on the passport cover or photo page.",
            "3.  Keep still until the scan completes — it may take a few seconds.",
        ].forEach { tip in
            stack.addArrangedSubview(makeLabel(tip, size: 13))
        }
    }

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: size, weight: weight)
        l.numberOfLines = 0
        return l
    }

    private func makeCircle(size: CGFloat, view: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = size / 2
        container.clipsToBounds = true
        container.widthAnchor.constraint(equalToConstant: size).isActive = true
        container.heightAnchor.constraint(equalToConstant: size).isActive = true

        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
        return container
    }

    // MARK: - Colors

    private func applyColors() {
        let colors = CachedData.shared.colors.current(for: traitCollection)
        view.backgroundColor = colors.backgroundColor
        titleLabel.textColor = colors.primaryColor
        subtitleLabel.textColor = colors.secondaryColor
        spinner.color = colors.primaryColor
        checkmarkLabel.textColor = colors.primaryColor
        errorDetailLabel.textColor = .systemRed
        tipsCard.backgroundColor = colors.backgroundColor.withAlphaComponent(0.06)
        tipsCard.layer.borderColor = colors.primaryColor.withAlphaComponent(0.12).cgColor
        tipsCard.layer.borderWidth = 1

        // Tips labels
        tipsCard.subviews.first?.subviews.forEach { v in
            (v as? UILabel)?.textColor = colors.secondaryColor
            if let l = v as? UILabel, l.font.pointSize == 14 {
                l.textColor = colors.primaryColor
            }
        }

        primaryButton.backgroundColor = colors.accentColor
        primaryButton.setTitleColor(.white, for: .normal)
        secondaryButton.backgroundColor = colors.backgroundColor
        secondaryButton.setTitleColor(colors.primaryColor, for: .normal)
        secondaryButton.layer.borderColor = colors.primaryColor.withAlphaComponent(0.3).cgColor
        secondaryButton.layer.borderWidth = 1

        shareLogButton.setTitleColor(.systemGreen, for: .normal)
        shareLogButton.layer.borderColor = UIColor.systemGreen.cgColor
        shareLogButton.backgroundColor = UIColor.black.withAlphaComponent(0.85)

        // Error/success circle backgrounds
        if let errorCircle = errorIconLabel.superview {
            errorCircle.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
            errorIconLabel.textColor = .systemRed
        }
        if let checkCircle = checkmarkLabel.superview {
            checkCircle.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
            checkmarkLabel.textColor = .systemGreen
        }
    }

    // MARK: - State → UI

    private func updateUI() {
        let colors = CachedData.shared.colors.current(for: traitCollection)

        // Hide everything, then show what's needed
        rippleContainer.isHidden         = true
        tipsCard.isHidden                = true
        spinner.stopAnimating()
        checkmarkLabel.superview?.isHidden = true
        errorIconLabel.superview?.isHidden = true
        errorDetailLabel.isHidden        = true
        shareLogButton.isHidden          = true
        primaryButton.isHidden           = false
        secondaryButton.isHidden         = false

        switch state {
        case .idle:
            titleLabel.text    = "Scan Passport Chip"
            subtitleLabel.text = "We will read the electronic chip in your passport for secure verification."
            rippleContainer.isHidden = false
            tipsCard.isHidden        = false
            stopRipple()
            drawNfcBadge(color: colors.accentColor)
            primaryButton.setTitle("Start Scanning", for: .normal)
            secondaryButton.setTitle("Cancel", for: .normal)

        case .scanning:
            titleLabel.text    = "Scanning..."
            subtitleLabel.text = "Hold your phone flat against the passport cover near the chip symbol."
            rippleContainer.isHidden = false
            startRipple(color: colors.accentColor)
            primaryButton.isHidden   = true
            secondaryButton.setTitle("Cancel", for: .normal)

        case .verifying:
            titleLabel.text    = "Verifying Passport"
            subtitleLabel.text = "Verifying your identity..."
            spinner.startAnimating()
            primaryButton.isHidden   = true
            secondaryButton.isHidden = true

        case .success:
            titleLabel.text    = "Passport Verified"
            subtitleLabel.text = "Your passport chip was read and verified successfully."
            checkmarkLabel.superview?.isHidden = false
            primaryButton.setTitle("Continue", for: .normal)
            secondaryButton.isHidden = true

        case .error(let msg):
            titleLabel.text    = "Scan Failed"
            subtitleLabel.text = ""
            errorIconLabel.superview?.isHidden = false
            errorDetailLabel.isHidden  = false
            errorDetailLabel.text      = msg
            shareLogButton.isHidden    = (shareableLog == nil)
            primaryButton.setTitle("Try Again", for: .normal)
            secondaryButton.setTitle("Cancel", for: .normal)
        }
    }

    // MARK: - Ripple animation

    private func drawNfcBadge(color: UIColor) {
        rippleLayers.forEach { $0.removeFromSuperlayer() }
        rippleLayers.removeAll()

        let size: CGFloat = 70
        let badge = CAShapeLayer()
        badge.path = UIBezierPath(ovalIn: CGRect(
            x: (120 - size) / 2, y: (120 - size) / 2, width: size, height: size
        )).cgPath
        badge.fillColor = color.cgColor
        rippleContainer.layer.addSublayer(badge)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        label.text = "NFC"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        rippleContainer.addSubview(label)
    }

    private func startRipple(color: UIColor) {
        drawNfcBadge(color: color)
        rippleTimer?.invalidate()
        var delay = 0.0
        (0..<3).forEach { _ in
            let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                self?.addRipplePulse(color: color)
            }
            RunLoop.main.add(timer, forMode: .common)
            delay += 0.6
        }
        // Repeat
        rippleTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { [weak self] _ in
            guard let self, case .scanning = self.state else { return }
            self.startRipple(color: color)
        }
        RunLoop.main.add(rippleTimer!, forMode: .common)
    }

    private func addRipplePulse(color: UIColor) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(x: 10, y: 10, width: 100, height: 100)).cgPath
        layer.fillColor = color.withAlphaComponent(0.5).cgColor
        rippleContainer.layer.insertSublayer(layer, at: 0)

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.0
        scale.toValue   = 2.5

        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 0.6
        opacity.toValue   = 0.0

        let group = CAAnimationGroup()
        group.animations = [scale, opacity]
        group.duration   = 1.8
        group.fillMode   = .forwards
        group.isRemovedOnCompletion = true
        group.delegate   = RippleAnimationDelegate { layer.removeFromSuperlayer() }
        layer.add(group, forKey: "ripple")
    }

    private func stopRipple() {
        rippleTimer?.invalidate()
        rippleTimer = nil
    }

    // MARK: - Button actions

    @objc private func primaryTapped() {
        switch state {
        case .idle:    startScanning()
        case .success: Task { await delegate?.didFinishValidationStepNumber(0) }
        case .error:   state = .idle
        default:       break
        }
    }

    @objc private func secondaryTapped() {
        switch state {
        case .scanning:
            state = .idle
        default:
            Task { await delegate?.didCancel() }
        }
    }

    @objc private func shareLog() {
        guard let log = shareableLog else { return }
        let vc = UIActivityViewController(activityItems: [log], applicationActivities: nil)
        present(vc, animated: true)
    }

    // MARK: - Scan logic

    private func startScanning() {
        guard let docNumber = CachedData.shared.passportDocumentNumber.nilIfEmpty,
              let dob       = CachedData.shared.passportDateOfBirth.nilIfEmpty,
              let expiry    = CachedData.shared.passportExpiryDate.nilIfEmpty else {
            state = .error("Passport data is missing. Please provide document number, date of birth, and expiry date.")
            return
        }

        state = .scanning

        Task { @MainActor in
            var nfcResult: NfcPassportResult
            do {
                nfcResult = try await reader.readPassport(
                    documentNumber: docNumber,
                    dateOfBirth: dob,
                    expiryDate: expiry
                )
            } catch {
                let logs = NfcLogStore.shared.snapshot()
                let logText = logs.map { "[\($0["ts"]!)][\($0["level"]!)][\($0["tag"]!)] \($0["message"]!)" }.joined(separator: "\n")
                shareableLog = "=== NFC CHIP LOGS ===\n\(Date().ISO8601Format())\n\n\(logText)\n\nError: \(error.localizedDescription)"
                state = .error(error.localizedDescription)
                return
            }

            if let err = nfcResult.error {
                state = .error(err)
                return
            }

            guard let dg1 = nfcResult.dg1Base64, let dg2 = nfcResult.dg2Base64, let sod = nfcResult.sodBase64 else {
                let missing = [
                    nfcResult.dg1Base64 == nil ? "DG1" : nil,
                    nfcResult.dg2Base64 == nil ? "DG2" : nil,
                    nfcResult.sodBase64 == nil ? "SOD" : nil,
                ].compactMap { $0 }.joined(separator: ", ")
                state = .error("Missing chip data (\(missing)).")
                return
            }

            CachedData.shared.nfcResult = nfcResult
            state = .verifying

            await verifyWithBackend(dg1Base64: dg1, dg2Base64: dg2, sodBase64: sod, authType: nfcResult.authMethod)
        }
    }

    private func verifyWithBackend(dg1Base64: String, dg2Base64: String, sodBase64: String, authType: String) async {
        let url = "\(CachedData.shared.apiBaseUrl)/api/DigitalIdentity/verify/passport/nfc"
        let request = NfcVerifyPost.Request(
            transactionId: CachedData.shared.transactionId,
            dg1Base64: dg1Base64,
            dg2Base64: dg2Base64,
            sodBase64: sodBase64,
            authType: authType
        )

        let headers = HTTPHeaders([
            "Content-Type":  "application/json",
            "Accept":        "*/*",
            "ApiKey":        CachedData.shared.apiKey,
            "TenancyName":   CachedData.shared.tenancyName,
            "Authorization": "Bearer \(CachedData.shared.accessToken)",
        ])

        let dataResponse = await AF.request(
            url,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: headers
        ).serializingData().response

        // Surface HTTP-level errors
        if let httpResponse = dataResponse.response {
            let statusCode = httpResponse.statusCode
            if !(200..<300).contains(statusCode) {
                let body = dataResponse.data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                let msg = "Server error (\(statusCode))\(body.isEmpty ? "" : ": \(body)")"
                shareableLog = "=== NFC SCAN REPORT ===\n\(Date().ISO8601Format())\n\nPOST \(url)\n\(msg)"
                state = .error(msg)
                return
            }
        }

        if let networkError = dataResponse.error {
            let log = "POST \(url)\n\nError: \(networkError.localizedDescription)"
            shareableLog = "=== NFC SCAN REPORT ===\n\(Date().ISO8601Format())\n\n\(log)"
            state = .error("Network error: \(networkError.localizedDescription)")
            return
        }

        guard let rawData = dataResponse.data, !rawData.isEmpty else {
            state = .error("Server returned an empty response.")
            return
        }

        let response: NfcVerifyPost.Response
        do {
            response = try JSONDecoder().decode(NfcVerifyPost.Response.self, from: rawData)
        } catch {
            let body = String(data: rawData, encoding: .utf8) ?? "(unreadable)"
            shareableLog = "=== NFC SCAN REPORT ===\n\(Date().ISO8601Format())\n\nPOST \(url)\n\nRaw response:\n\(body)"
            state = .error("Could not parse server response.")
            return
        }

        CachedData.shared.nfcVerifyResponse = response.data

        if let errorMsg = response.errorMessage, !errorMsg.isEmpty {
            let log = buildDebugLog(url: url, request: request, responseBody: response)
            shareableLog = log
            state = .error(errorMsg)
            return
        }

        if response.data?.isValid == false {
            let reason = response.data?.failureReason ?? "Passport verification failed."
            let log = buildDebugLog(url: url, request: request, responseBody: response)
            shareableLog = log
            state = .error(reason)
            return
        }

        state = .success
    }

    private func buildDebugLog(url: String, request: NfcVerifyPost.Request, responseBody: NfcVerifyPost.Response) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let responseJson = (try? encoder.encode(responseBody)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        let nfcLogs = NfcLogStore.shared.snapshot()
            .map { "[\($0["ts"]!)][\($0["level"]!)][\($0["tag"]!)] \($0["message"]!)" }
            .joined(separator: "\n")

        return """
        === NFC SCAN REPORT ===
        \(Date().ISO8601Format())

        POST \(url)

        ── Request ──
        transaction_id: \(request.transactionId)
        auth_type: \(request.authType)
        dg1_base64: [\(request.dg1Base64.count) chars]
        dg2_base64: [\(request.dg2Base64.count) chars]
        sod_base64: [\(request.sodBase64.count) chars]

        ── Response ──
        \(responseJson)

        ── NFC Chip Logs ──
        \(nfcLogs)
        """
    }

    // MARK: - Cleanup

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopRipple()
    }
}

// MARK: - Helpers

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

/// CAAnimationDelegate helper that fires a closure on completion.
private final class RippleAnimationDelegate: NSObject, CAAnimationDelegate {
    private let onComplete: () -> Void
    init(_ onComplete: @escaping () -> Void) { self.onComplete = onComplete }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) { onComplete() }
}
