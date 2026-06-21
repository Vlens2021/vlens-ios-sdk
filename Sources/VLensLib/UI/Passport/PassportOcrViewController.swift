import UIKit
import AVFoundation
internal import Alamofire

/// Camera capture screen for passport photo-page OCR.
/// Captures the front page, calls the passport OCR endpoint, stores
/// document number / DOB / expiry in CachedData, then advances to NFC.
class PassportOcrViewController: UIViewController {

    static func instance() -> PassportOcrViewController {
        PassportOcrViewController()
    }

    var delegate: ValidationMainViewControllerDelegate?

    // MARK: - Camera

    private var captureSession   = AVCaptureSession()
    private var photoOutput      = AVCapturePhotoOutput()
    private var previewLayer     : AVCaptureVideoPreviewLayer?
    private var isAutoCapturing  = true
    private var hasCapture       = false

    // MARK: - UI

    private let previewView      = UIView()
    private let overlayView      = PassportOcrOverlayView()
    private let instructionLabel : UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 2
        l.text = "Place your passport open to the photo page.\nAlign the MRZ zone at the bottom inside the frame."
        l.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        l.layer.cornerRadius = 8
        l.clipsToBounds = true
        return l
    }()
    private let captureButton    : UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Capture", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 32
        b.layer.borderWidth = 3
        b.layer.borderColor = UIColor.white.cgColor
        return b
    }()
    private let cancelButton     : UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.setTitleColor(.white, for: .normal)
        return b
    }()
    private let loadingView      : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        v.isHidden = true
        return v
    }()
    private let spinner          = UIActivityIndicatorView(style: .large)
    private let loadingLabel     : UILabel = {
        let l = UILabel()
        l.text = "Scanning passport..."
        l.textColor = .white
        l.font = .systemFont(ofSize: 15, weight: .medium)
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        setupCamera()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
        isAutoCapturing = CachedData.shared.allowAutoCapture
        captureButton.isHidden = isAutoCapturing
        // Auto-capture timeout fallback
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
            self?.isAutoCapturing = false
            self?.captureButton.isHidden = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    // MARK: - Layout

    private func setupLayout() {
        [previewView, overlayView, instructionLabel, captureButton, cancelButton, loadingView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        // Loading overlay
        spinner.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        spinner.color = .white

        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            instructionLabel.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -24),

            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            captureButton.widthAnchor.constraint(equalToConstant: 64),
            captureButton.heightAnchor.constraint(equalToConstant: 64),

            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -20),
            loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
        ])

        captureButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        let colors = CachedData.shared.colors.current(for: traitCollection)
        captureButton.backgroundColor = colors.accentColor

        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    // MARK: - Camera setup

    private func setupCamera() {
        captureSession.sessionPreset = .photo
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) { captureSession.addInput(input) }
            if captureSession.canAddOutput(photoOutput) { captureSession.addOutput(photoOutput) }

            let layer = AVCaptureVideoPreviewLayer(session: captureSession)
            layer.videoGravity = .resizeAspectFill
            previewView.layer.addSublayer(layer)
            previewLayer = layer
        } catch {
            debugPrint("[PassportOCR] Camera setup error: \(error)")
        }
    }

    // MARK: - Capture

    @objc private func captureButtonTapped() {
        guard !hasCapture else { return }
        capturePhoto()
    }

    @objc private func cancelTapped() {
        Task { await delegate?.didCancel() }
    }

    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func process(image: UIImage) {
        hasCapture = true
        captureSession.stopRunning()
        showLoading(true)

        guard let jpeg = image.jpegData(compressionQuality: 0.85) else {
            showLoading(false)
            showError("Failed to process image.")
            return
        }
        let base64 = (Utils.compressBase64Image(jpeg.base64EncodedString())) ?? jpeg.base64EncodedString()

        Task { @MainActor in
            await callOcrApi(imageBase64: base64)
        }
    }

    private func callOcrApi(imageBase64: String) async {
        let url = "\(CachedData.shared.apiBaseUrl)/api/DigitalIdentity/verify/passport/scan"
        let request = VerifyPassportOcrPost.Request(
            transactionId: CachedData.shared.transactionId,
            image: imageBase64,
            getExtractedData: true
        )
        let headers = HTTPHeaders([
            "Content-Type":  "application/json",
            "Accept":        "*/*",
            "ApiKey":        CachedData.shared.apiKey,
            "TenancyName":   CachedData.shared.tenancyName,
            "Authorization": "Bearer \(CachedData.shared.accessToken)",
        ])

        // Use serializingData() so we can inspect the raw response even if the body is
        // empty or the status code indicates an error — avoids Alamofire's
        // "input data was nil or zero length" crash on empty server responses.
        let dataResponse = await AF.request(
            url,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: headers
        ).serializingData().response

        showLoading(false)

        // Surface HTTP-level errors first
        if let httpResponse = dataResponse.response {
            let statusCode = httpResponse.statusCode
            if statusCode == 401 {
                showError("Unauthorized — check your API key or access token.")
                return
            }
            if statusCode == 403 {
                showError("Access denied. Check tenancy name and API key.")
                return
            }
            if !(200..<300).contains(statusCode) {
                let body = dataResponse.data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                showError("Server error (\(statusCode))\(body.isEmpty ? "" : ": \(body)")")
                return
            }
        }

        if let networkError = dataResponse.error {
            showError("Network error: \(networkError.localizedDescription)")
            return
        }

        guard let rawData = dataResponse.data, !rawData.isEmpty else {
            showError("Server returned an empty response. Please try again.")
            return
        }

        let response: VerifyPassportOcrPost.Response
        do {
            response = try JSONDecoder().decode(VerifyPassportOcrPost.Response.self, from: rawData)
        } catch {
            let body = String(data: rawData, encoding: .utf8) ?? "(unreadable)"
            showError("Could not parse server response: \(body)")
            return
        }

        if let errMsg = response.errorMessage, !errMsg.isEmpty {
            showError(errMsg)
            return
        }

        guard
            let data       = response.data,
            let passportNo = data.passportNumber, !passportNo.isEmpty,
            let dob        = data.dateOfBirth,    !dob.isEmpty,
            let expiry     = data.expiryDate,     !expiry.isEmpty
        else {
            showError("Could not extract passport data. Please try again.")
            return
        }

        CachedData.shared.passportDocumentNumber = passportNo.trimmingCharacters(in: .whitespaces).uppercased()
        CachedData.shared.passportDateOfBirth    = toYYMMDD(dob)
        CachedData.shared.passportExpiryDate     = toYYMMDD(expiry)

        await delegate?.didFinishValidationStepNumber(0)
    }

    // MARK: - Helpers

    private func showLoading(_ show: Bool) {
        loadingView.isHidden = !show
        if show { spinner.startAnimating() } else { spinner.stopAnimating() }
    }

    private func showError(_ message: String) {
        hasCapture = false
        let alert = UIAlertController(title: "Scan Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            DispatchQueue.global(qos: .userInitiated).async { self?.captureSession.startRunning() }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            Task { await self?.delegate?.didCancel() }
        })
        present(alert, animated: true)
    }

    /// Converts common date formats to YYMMDD required by the NFC stack.
    private func toYYMMDD(_ input: String) -> String {
        let clean = input.trimmingCharacters(in: .whitespaces)

        // Already YYMMDD (6 digits)
        let digitsOnly = clean.filter { $0.isNumber }
        if digitsOnly.count == 6 { return digitsOnly }

        // YYYYMMDD (8 digits) → YYMMDD
        if digitsOnly.count == 8 { return String(digitsOnly.dropFirst(2)) }

        // DD/MM/YYYY or YYYY-MM-DD
        let parts = clean.components(separatedBy: CharacterSet(charactersIn: "/-."))
        if parts.count == 3 {
            if parts[0].count == 4 {
                // YYYY-MM-DD
                let yy = String(parts[0].suffix(2))
                let mm = parts[1].count == 1 ? "0\(parts[1])" : parts[1]
                let dd = parts[2].count == 1 ? "0\(parts[2])" : parts[2]
                return "\(yy)\(mm)\(dd)"
            } else {
                // DD/MM/YYYY
                let dd = parts[0].count == 1 ? "0\(parts[0])" : parts[0]
                let mm = parts[1].count == 1 ? "0\(parts[1])" : parts[1]
                let yyyy = parts[2]
                let yy = yyyy.count == 4 ? String(yyyy.suffix(2)) : yyyy
                return "\(yy)\(mm)\(dd)"
            }
        }

        return digitsOnly
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension PassportOcrViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let data  = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        DispatchQueue.main.async { self.process(image: image) }
    }
}

// MARK: - Overlay view (frame + MRZ strip highlight)

private final class PassportOcrOverlayView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Dim the whole screen
        UIColor.black.withAlphaComponent(0.55).setFill()
        ctx.fill(rect)

        // Cut out a passport-shaped window (roughly 85.6×54mm, landscape in camera)
        let w = rect.width * 0.88
        let h = w * 0.63          // A4-ish aspect ratio for passport booklet open
        let x = (rect.width - w) / 2
        let y = (rect.height - h) / 2
        let hole = CGRect(x: x, y: y, width: w, height: h)

        ctx.setBlendMode(.clear)
        UIColor.clear.setFill()
        UIBezierPath(roundedRect: hole, cornerRadius: 8).fill()

        // White border around the cutout
        ctx.setBlendMode(.normal)
        UIColor.white.withAlphaComponent(0.8).setStroke()
        let border = UIBezierPath(roundedRect: hole.insetBy(dx: -1, dy: -1), cornerRadius: 9)
        border.lineWidth = 2
        border.stroke()

        // MRZ strip highlight at bottom of cutout
        let mrzH: CGFloat = h * 0.18
        let mrzRect = CGRect(x: x, y: hole.maxY - mrzH, width: w, height: mrzH)
        UIColor.systemYellow.withAlphaComponent(0.25).setFill()
        UIBezierPath(roundedRect: mrzRect, cornerRadius: 0).fill()

        // "MRZ" label inside strip
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8),
        ]
        let str = NSAttributedString(string: "MRZ ZONE", attributes: attrs)
        let strSize = str.size()
        str.draw(at: CGPoint(x: x + 6, y: hole.maxY - mrzH + (mrzH - strSize.height) / 2))
    }
}
