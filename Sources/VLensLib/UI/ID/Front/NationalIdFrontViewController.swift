//
//  NationalIdFrontViewController.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import UIKit
internal import Alamofire
import AVFoundation
import Vision

class NationalIdFrontViewController: UIViewController {

    static func instance() -> NationalIdFrontViewController {
        let viewController = NationalIdFrontViewController()
        return viewController
    }
    
    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var cardOverlayView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var captureButtonView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let videoOutput = AVCaptureVideoDataOutput()
    private var isProcessing = true
    
    private var isAutoCapturing: Bool = true
    
    var viewModel = NationalIdFrontViewModel()
    var delegate: ValidationMainViewControllerDelegate? = nil
    
    public init() {
        super.init(nibName: "NationalIdFrontViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DatadogService.shared.rumStartView(key: "national_id_front", name: "Front ID Screen")
        DatadogService.shared.info("Front ID screen displayed")
        setupCamera()
//        setupCaptureButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatadogService.shared.rumStopView(key: "national_id_front")
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            captureSession?.stopRunning()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isProcessing = true

        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }
        }

        isAutoCapturing = CachedData.shared.allowAutoCapture
        captureButtonView.isHidden = isAutoCapturing

        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            self.isAutoCapturing = false
            self.captureButtonView.isHidden = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isProcessing = false
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraPreviewView.bounds
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        Task {
            await delegate?.didBackToPreviousStep()
        }
    }
    
    @IBAction func flashButtonAction(_ sender: Any) {
        Task {
            
        }
    }
    
    @IBAction func captureButtonAction(_ sender: Any) {
        capturePhoto()
    }
    
    private func didCaptureImage(_ image: UIImage) {
        Task {
            guard let imageBase64String = image.jpegData(compressionQuality: 1)?.base64EncodedString() else { return }
            let compressedBase64 = Utils.compressBase64Image(imageBase64String) ?? imageBase64String
            do {
                try await viewModel.postData(imageBase64: compressedBase64)
                CachedData.shared.didGetVerifyFrontResponseSuccessfully = true
            } catch {
                debugPrint(error)
                CachedData.shared.didGetVerifyFrontResponseSuccessfully = false
            }
        }
        
        Task {
            await delegate?.didFinishValidationStepNumber(1)
        }
    }

}

extension NationalIdFrontViewController {
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            debugPrint("❌ Unable to access back camera")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = cameraPreviewView.bounds
            cameraPreviewView.layer.addSublayer(previewLayer)

            // Set video frame delegate
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            Task { @MainActor in
                let session = captureSession
                let soundsEnabled = CachedData.shared.enableSounds

                DispatchQueue.global(qos: .userInitiated).async {
                    if !soundsEnabled {
                        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
                        try? AVAudioSession.sharedInstance().setActive(true)
                    }
                    session?.startRunning()
                }
            }
            
        } catch {
            debugPrint("❌ Error setting up camera input: \(error)")
        }
    }
    
//    @MainActor
//    func detectRectangle(in image: CGImage) {
//        guard isProcessing == false else { return }
//        isProcessing = true
//        
//        let request = VNDetectRectanglesRequest { [weak self] request, error in
//            guard let self = self else { return }
//
//            if let results = request.results as? [VNRectangleObservation],
//               let _ = results.first{
//                self.capturePhoto()
//            } else {
//                isProcessing = false
//            }
//        }
//
//        request.minimumConfidence = 0.8
//        request.minimumAspectRatio = 0.3
//        request.maximumObservations = 1
//
//        let handler = VNImageRequestHandler(cgImage: image, orientation: .right, options: [:])
//
//        Task { @MainActor in
//            try? handler.perform([request])
//        }
//    }
    
    @MainActor
    func detectFace(in image: CGImage) {
        guard isProcessing == false else { return }
        isProcessing = true
        
        let detector = FaceDetector()

        Task {
            do {
                let hasFace = try await detector.detectFace(in: image)
                if hasFace {
                    //debugPrint("✅ Face detected")
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    self.capturePhoto()
                } else {
                    self.isProcessing = false
                   // print("❌ No face detected")
                }
            } catch {
                print("Face detection failed:", error)
            }
        }
    }
    
    private func setupCaptureButton() {
        let captureButton = UIButton(type: .system)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.setTitle("📸 Capture", for: .normal)
        captureButton.backgroundColor = .white
        captureButton.setTitleColor(.black, for: .normal)
        captureButton.layer.cornerRadius = 25
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        view.addSubview(captureButton)

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            captureButton.widthAnchor.constraint(equalToConstant: 100),
            captureButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension NationalIdFrontViewController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            debugPrint("❌ Failed to get image from photo capture")
            return
        }

        debugPrint("✅ Photo captured")
        
        Task { @MainActor in
            captureSession?.stopRunning()
            didCaptureImage(image)
        }

    }
}


extension NationalIdFrontViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Perform image conversion on background thread
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        // Now pass CGImage to the main actor for UI-related detection
        Task { @MainActor in
//            self.detectRectangle(in: cgImage)
            if (isAutoCapturing == true) {
                self.detectFace(in: cgImage)
            }
        }
    }
}
