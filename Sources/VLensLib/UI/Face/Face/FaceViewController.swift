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

    private var sceneView: ARSCNView!
    private var isProcessing: Bool = false
    
    var delegate: ValidationMainViewControllerDelegate? = nil
    var viewModel: FaceValidationViewModel? = nil
    
    private let createdDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize ARSCNView
        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.delegate = self
        sceneView.session = ARSession()
        sceneView.automaticallyUpdatesLighting = true
        self.cameraPreview.addSubview(sceneView)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Start ARKit face tracking
            let configuration = ARFaceTrackingConfiguration()
            self.sceneView.session.run(configuration)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView?.frame = cameraPreview.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
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
            print("\(fileName) MP3 file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func playSuccessSound() {
        let fileName = "success"
        guard let url = Bundle.module.url(forResource: fileName, withExtension: "mp3") else {
            print("\(fileName) MP3 file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    nonisolated func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Extract thread-safe data first
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        let blendShapes = faceAnchor.blendShapes
        let transform = faceAnchor.transform

        Task { @MainActor in
            await rendererFrame(blendShapes: blendShapes, transform: transform)
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
        
        let currentImage = sceneView.snapshot()

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
