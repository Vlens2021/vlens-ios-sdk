//
//  FaceViewController.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation

class FaceViewController: UIViewController, ARSCNViewDelegate {

    static func instance() -> FaceViewController {
        let viewController = FaceViewController()
        return viewController
    }

    public init() {
        super.init(nibName: "FaceViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var hintImageView: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!

    var audioPlayer: AVAudioPlayer?

    // TrueDepth path
    private var sceneView: ARSCNView?
    private var isProcessing: Bool = false

    // Fallback path (no TrueDepth)
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureTimer: Timer?

    var delegate: ValidationMainViewControllerDelegate? = nil
    var viewModel: FaceValidationViewModel? = nil

    private let createdDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        if ARFaceTrackingConfiguration.isSupported {
            setupARKitSession()
        } else {
            setupFallbackCameraSession()
        }
    }

    // MARK: - TrueDepth path

    private func setupARKitSession() {
        let arView = ARSCNView(frame: self.view.frame)
        arView.delegate = self
        arView.session = ARSession()
        arView.automaticallyUpdatesLighting = true
        cameraPreview.addSubview(arView)
        sceneView = arView

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let configuration = ARFaceTrackingConfiguration()
            arView.session.run(configuration)
        }
    }

    // MARK: - Fallback path (regular front camera, auto-capture every 3 s)

    private func setupFallbackCameraSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        let output = AVCapturePhotoOutput()
        guard session.canAddInput(input), session.canAddOutput(output) else { return }
        session.addInput(input)
        session.addOutput(output)

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = cameraPreview.bounds
        cameraPreview.layer.addSublayer(preview)

        captureSession = session
        photoOutput = output
        previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        captureTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.captureFallbackPhoto()
        }
    }

    private func captureFallbackPhoto() {
        guard !isProcessing else { return }
        isProcessing = true
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView?.frame = cameraPreview.bounds
        previewLayer?.frame = cameraPreview.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView?.session.pause()
        captureTimer?.invalidate()
        captureSession?.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playSound()
        
        hintLabel.text = (viewModel?.currentType.title as? String)?.localized
        hintImageView.image = UIImage(named: viewModel?.getImageName() ?? "Smile".localized, in: .module, with: .none)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        Task {
            await self.delegate?.didBackToPreviousStep()
        }
    }
    
    @IBAction func torchButtonAction(_ sender: Any) {
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // Only allows portrait mode
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    func playSound() {
        let fileName = ((CachedData.shared.language == "en") ? viewModel?.getSoundFileName() : viewModel?.getSoundFileNameAr()) ?? "smile"
        guard let url = Bundle.module.url(forResource: fileName, withExtension: "mp3") else {
            debugPrint("\(fileName) MP3 file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            debugPrint("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func playSuccessSound() {
        let fileName = "success"
        guard let url = Bundle.module.url(forResource: fileName, withExtension: "mp3") else {
            debugPrint("\(fileName) MP3 file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            debugPrint("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    nonisolated func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Extract thread-safe data first
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        let blendShapes = faceAnchor.blendShapes
        let transform = faceAnchor.transform

        Task { @MainActor in
            rendererFrame(blendShapes: blendShapes, transform: transform)
        }

        
    }
    
    // ARSCNViewDelegate method to handle face tracking updates
    private func rendererFrame(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber], transform: simd_float4x4) {
        guard let viewModel else { return }
//        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        if (createdDate.timeIntervalSinceNow > -10) {
            return
        }
        
        if (isProcessing == true ) {
            return
        }
        
        isProcessing = true

        guard let currentImage = sceneView?.snapshot() else {
            isProcessing = false
            return
        }

        let type = viewModel.currentType
        
        if (type == .smile) {
            let isSmile = self.isSmile(blendShapes: blendShapes)
            if (isSmile) {
                DispatchQueue.main.async { [self] in
                    viewModel.face = currentImage.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                    playSuccessSound()
                    Task {
                        await delegate?.didFinishValidationStepNumber(viewModel.getStepIndex())
                    }
                }
                
                return
            }
        }
        
        if (type == .blink) {
            let isBlinking = self.isBlinking(blendShapes: blendShapes)
            if (isBlinking) {
                DispatchQueue.main.async { [self] in
                    viewModel.face = currentImage.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                    playSuccessSound()
                    Task {
                        await delegate?.didFinishValidationStepNumber(viewModel.getStepIndex())
                    }
                }
                
                return
            }
        }
        
        if (type == .turnHeadRight) {
            let isTurnRight = self.isTurnRight(transform: transform)
            if (isTurnRight) {
                DispatchQueue.main.async { [self] in
                    viewModel.face = currentImage.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                    playSuccessSound()
                    Task {
                        await delegate?.didFinishValidationStepNumber(viewModel.getStepIndex())
                    }
                }
                
                return
            }
        }
        
        if (type == .turnHeadLeft) {
            let isTurnLeft = self.isTurnLeft(transform: transform)
            if (isTurnLeft) {
                DispatchQueue.main.async { [self] in
                    viewModel.face = currentImage.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                    playSuccessSound()
                    Task {
                        await delegate?.didFinishValidationStepNumber(viewModel.getStepIndex())
                    }
                }
                
                return
            }
        }
        
        if (type == .headStraight) {
            let isHeadStraight = self.isHeadStraight(transform: transform)
            if (isHeadStraight) {
                DispatchQueue.main.async { [self] in
                    viewModel.face = currentImage.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                    playSuccessSound()
                    Task {
                        await delegate?.didFinishValidationStepNumber(viewModel.getStepIndex())
                    }
                }
                
                return
            }
        }

//        let isSmile         = self.isSmile(blendShapes: faceAnchor.blendShapes)
//        let isBlinking      = self.isBlinking(blendShapes: faceAnchor.blendShapes)
//        let isTurnRight     = self.isTurnRight(faceAnchor: faceAnchor)
//        let isTurnLeft      = self.isTurnLeft(faceAnchor: faceAnchor)
//        let isHeadStraight  = self.isHeadStraight(faceAnchor: faceAnchor)
//
//        if ((type == .smile && isSmile)
//            || (type == .blink && isBlinking)
//            || (type == .turnHeadRight && isTurnRight)
//            || (type == .turnHeadLeft && isTurnLeft)
//            || (type == .headStraight && isHeadStraight)) {
//
//            DispatchQueue.main.async { [self] in
//                viewModel.face = currentImage.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
//                stepsDelegate?.didFinishValidationStepNumber(viewModel.getStepIndex())
//            }
//        }
        
        isProcessing = false
    }
    
    private func isSmile(blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber]) -> Bool {
        if let mouthSmileLeft = blendShapes[.mouthSmileLeft]?.floatValue,
           let mouthSmileRight = blendShapes[.mouthSmileRight]?.floatValue {
            if (mouthSmileLeft + mouthSmileRight)/2.0 > 0.5 {
                debugPrint("Smile detected!")
                return true
            }
        }
        
        return false
    }
    
    private func isBlinking(blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber]) -> Bool {
        if let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue,
           let eyeBlinkRight = blendShapes[.eyeBlinkRight]?.floatValue {
            if eyeBlinkLeft > 0.5 && eyeBlinkRight > 0.5 {
                debugPrint("Blink detected!")
                return true
            }
        }
        return false
    }
    
    private func isTurnRight(transform: simd_float4x4) -> Bool {
        let headRotationY = transform.columns.2.x
        return headRotationY > 0.23
    }

    private func isTurnLeft(transform: simd_float4x4) -> Bool {
        let headRotationY = transform.columns.2.x
        return headRotationY < -0.23
    }

    private func isHeadStraight(transform: simd_float4x4) -> Bool {
        let headRotationY = transform.columns.2.x
        return headRotationY > -0.2 && headRotationY < 0.2
    }
    
    private func isTurnRight(faceAnchor: ARFaceAnchor) -> Bool {
        let headRotationY = faceAnchor.transform.columns.2.x
        if headRotationY > 0.23 {
            return true
        }
        return false
    }

    private func isTurnLeft(faceAnchor: ARFaceAnchor) -> Bool {
        let headRotationY = faceAnchor.transform.columns.2.x
        if headRotationY < -0.23 {
            return true
        }
        return false
    }

    private func isHeadStraight(faceAnchor: ARFaceAnchor) -> Bool {
        let headRotationY = faceAnchor.transform.columns.2.x
        if headRotationY > -0.2 && headRotationY < 0.2 {
            return true
        }
        return false
    }

}

// MARK: - Fallback photo capture delegate

extension FaceViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            isProcessing = false
            return
        }

        viewModel?.face = image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""

        DispatchQueue.main.async { [self] in
            playSuccessSound()
            Task {
                await delegate?.didFinishValidationStepNumber(viewModel?.getStepIndex() ?? 0)
            }
        }
    }
}
