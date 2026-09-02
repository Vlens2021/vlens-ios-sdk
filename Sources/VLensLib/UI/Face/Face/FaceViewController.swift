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
    
    // Flag to track if gesture was successfully detected (prevents further processing)
    private var gestureDetected: Bool = false

    // Fallback path (no TrueDepth)
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureTimer: Timer?

    var delegate: ValidationMainViewControllerDelegate? = nil
    var viewModel: FaceValidationViewModel? = nil

    private var isReadyToDetect = false
    private var readyTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        DatadogService.shared.rumStartView(key: "face_validation", name: "Face Validation Screen")
        DatadogService.shared.info("Face validation screen displayed")
        if ARFaceTrackingConfiguration.isSupported {
            // TrueDepth available - use ARKit face tracking
            setupARKitSession()
        } else if CachedData.shared.allowNonTrueDepthFallback {
            // TrueDepth not available but fallback is enabled - use auto-capture
            setupFallbackCameraSession()
        } else {
            // TrueDepth not available and fallback is disabled - gracefully close SDK
            DispatchQueue.main.async { [weak self] in
                Task {
                    await self?.delegate?.didFailWithError("DEVICE_NOT_SUPPORTED")
                }
            }
            return
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
        // Session is started in viewDidAppear — no redundant timer needed here
    }

    // MARK: - Fallback path (regular front camera, auto-capture every 2 s)

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

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            gestureDetected = true
            isProcessing = true
            readyTimer?.invalidate()
            captureTimer?.invalidate()
            // Release the AR session fully so the next face VC can acquire the camera.
            // sceneView may already be nil if finishGestureDetection() ran first.
            sceneView?.session.pause()
            sceneView?.removeFromSuperview()
            sceneView = nil
            captureSession?.stopRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatadogService.shared.rumStopView(key: "face_validation")
        gestureDetected = true
        isProcessing = true
        readyTimer?.invalidate()
        captureTimer?.invalidate()
        sceneView?.session.pause()
        sceneView?.removeFromSuperview()
        sceneView = nil
        captureSession?.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Reset all processing flags for fresh start
        isProcessing = false
        gestureDetected = false
        isReadyToDetect = false
        
        playSound()

        hintLabel.text = (viewModel?.currentType.title as? String)?.localized
        hintImageView.image = UIImage(named: viewModel?.getImageName() ?? "Smile".localized, in: .module, with: .none)

        // Restart AR session. Re-create the ARSCNView if it was released on a previous appearance.
        if ARFaceTrackingConfiguration.isSupported {
            if sceneView == nil {
                setupARKitSession()
            }
            let configuration = ARFaceTrackingConfiguration()
            sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else if let captureSession = captureSession, !captureSession.isRunning {
            // Restart fallback camera session if it was stopped
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }

        // Reset detection gate — user must see the instruction before capturing starts
        readyTimer?.invalidate()
        readyTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.isReadyToDetect = true

            // Start fallback auto-capture after the ready delay (non-TrueDepth devices only)
            if let self, self.captureSession != nil && !ARFaceTrackingConfiguration.isSupported {
                self.captureTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                    self?.captureFallbackPhoto()
                }
            }
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        // Stop all processing immediately to ensure back button is responsive
        isProcessing = true
        gestureDetected = true
        readyTimer?.invalidate()
        captureTimer?.invalidate()
        sceneView?.session.pause()
        captureSession?.stopRunning()
        
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
        // Check if sounds are enabled
        guard CachedData.shared.enableSounds else { return }
        
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
        // Check if sounds are enabled
        guard CachedData.shared.enableSounds else { return }
        
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

        // Dispatch to main actor for UI updates
        Task { @MainActor in
            rendererFrame(blendShapes: blendShapes, transform: transform)
        }
    }
    
    /// Called once a valid gesture has been confirmed. Releases the AR camera so
    /// the next FaceViewController can acquire it without conflict, then advances the flow.
    private func finishGestureDetection(capturedImage: UIImage) {
        gestureDetected = true
        // Fully release the AR session and camera so the next face VC gets a clean start.
        sceneView?.session.pause()
        sceneView?.removeFromSuperview()
        sceneView = nil
        viewModel?.face = capturedImage.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
        playSuccessSound()
        Task {
            await delegate?.didFinishValidationStepNumber(viewModel?.getStepIndex() ?? 0)
        }
    }

    // ARSCNViewDelegate method to handle face tracking updates
    private func rendererFrame(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber], transform: simd_float4x4) {
        guard let viewModel else { return }
        
        // Skip if gesture was already detected or back was pressed
        guard !gestureDetected else { return }

        guard isReadyToDetect else { return }
        
        if (isProcessing == true ) {
            return
        }
        
        isProcessing = true

        guard let currentImage = sceneView?.snapshot() else {
            isProcessing = false
            return
        }

        let type = viewModel.currentType
        
        if type == .smile && isSmile(blendShapes: blendShapes) {
            finishGestureDetection(capturedImage: currentImage)
            return
        }

        if type == .blink && isBlinking(blendShapes: blendShapes) {
            finishGestureDetection(capturedImage: currentImage)
            return
        }

        if type == .turnHeadRight && isTurnRight(transform: transform) {
            finishGestureDetection(capturedImage: currentImage)
            return
        }

        if type == .turnHeadLeft && isTurnLeft(transform: transform) {
            finishGestureDetection(capturedImage: currentImage)
            return
        }

        if type == .headStraight && isHeadStraight(transform: transform) {
            finishGestureDetection(capturedImage: currentImage)
            return
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
