//
//  NationalIdFrontViewController.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import UIKit
internal import RxSwift
internal import RxCocoa
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
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let videoOutput = AVCaptureVideoDataOutput()
    private var isCapturing = true
    
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
        
        setupCamera()
//        setupCaptureButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isCapturing = false
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
    
    private func didCaptureImage(_ image: UIImage) {
        Task {
            guard let imageBase64String = image.jpegData(compressionQuality: 1)?.base64EncodedString() else { return }
            do {
                await try viewModel.postData(imageBase64: imageBase64String)
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
            print("❌ Unable to access back camera")
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
                captureSession.startRunning()
            }
        } catch {
            print("❌ Error setting up camera input: \(error)")
        }
    }
    
    @MainActor
    func detectRectangle(in image: CGImage) {
        guard isCapturing == false else { return }
        
        let request = VNDetectRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }

            if let results = request.results as? [VNRectangleObservation],
               let _ = results.first,
               !self.isCapturing {
                self.isCapturing = true
                self.capturePhoto()
            }
        }

        request.minimumConfidence = 0.8
        request.minimumAspectRatio = 0.3
        request.maximumObservations = 1

        let handler = VNImageRequestHandler(cgImage: image, orientation: .right, options: [:])

        Task { @MainActor in
            try? handler.perform([request])
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
            print("❌ Failed to get image from photo capture")
            return
        }

        print("✅ Photo captured")
        
        Task { @MainActor in
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
            self.detectRectangle(in: cgImage)
        }
    }
}
