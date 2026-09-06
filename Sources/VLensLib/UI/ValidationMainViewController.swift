//
//  ValidationMainViewController.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import UIKit

protocol ValidationMainViewControllerDelegate {
    func didBackToPreviousStep() async
    func didFinishValidationStepNumber(_ stepNumber: Int) async
    func didRetry(stepNumber: Int) async
    func didCancel() async
    func didFailWithError(_ error: String) async
}

class ValidationMainViewController: UIViewController {

    static func instance(withLivenessOnly: Bool) -> ValidationMainViewController {
        let viewController = ValidationMainViewController()
        viewController.viewModel.withLivenessOnly = withLivenessOnly
        return viewController
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var loadingTitleLabel: UILabel!
    @IBOutlet weak var loadingMessageLabel: UILabel!
    
    @IBOutlet weak var actionsView: UIStackView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var delegate: VLensDelegate? = nil
    
    private let startNationalIdValidationViewController      : StartNationalIdValidationViewController  = .instance()
    private var nationalIdFrontValidationViewController      : NationalIdFrontViewController            = .instance()
    private var nationalIdBackValidationViewController       : NationalIdBackViewController             = .instance()
    private var idReviewViewController                       : IdReviewViewController                   = .instance()
    private let startFaceValidationViewController            : StartFaceValidationViewController        = .instance()
    private var face1ValidationViewController                : FaceViewController                       = .instance()
    private var face2ValidationViewController                : FaceViewController                       = .instance()
    private var face3ValidationViewController                : FaceViewController                       = .instance()
    
    private var currentChildViewController: UIViewController? = nil
    private var isPostingLiveness = false

    private let viewModel = ValidationMainViewModel()
    
    public init() {
        super.init(nibName: "ValidationMainViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let colors = CachedData.shared.colors.current(for: traitCollection)
        view.backgroundColor = colors.backgroundColor
        loadingTitleLabel.textColor = colors.primaryColor

        if var retryConfig = retryButton.configuration {
            retryConfig.baseBackgroundColor = colors.accentColor
            retryButton.configuration = retryConfig
        }
        closeButton.tintColor = colors.primaryColor

        // Set custom client logo if provided
        if let clientLogo = CachedData.shared.clientLogoImage {
            logoImageView?.image = clientLogo
            logoImageView?.contentMode = .scaleAspectFit
        }
        
        viewModel.initData()
        
        initViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        lockOrientationToPortrait()
        initViews()
    }
    
    
    private func initViews() {
        initViewsForStep(0)
        loadingView.isHidden = true
        loadingImageView.image = UIImage.gifImageWithName("person_scan_final")
        actionsView.isHidden = true
        loadingMessageLabel.text = "processing_your_id".localized
        addGifBackground(to: loadingImageView)
    }

    private func addGifBackground(to imageView: UIImageView) {
        guard let bgImage = UIImage(named: "gif_background", in: .module, compatibleWith: nil) else { return }
        let colors = CachedData.shared.colors.current(for: traitCollection)
        let tintedBg = bgImage.tinted(with: colors.accentColor)

        let bgView = UIImageView(image: tintedBg)
        bgView.contentMode = .scaleAspectFill
        bgView.clipsToBounds = true
        bgView.translatesAutoresizingMaskIntoConstraints = false

        guard let parent = imageView.superview else { return }
        parent.insertSubview(bgView, belowSubview: imageView)
        NSLayoutConstraint.activate([
            bgView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            bgView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            bgView.widthAnchor.constraint(equalToConstant: 243),
            bgView.heightAnchor.constraint(equalToConstant: 243)
        ])
    }
    
    private func initViewsForStep(_ index: Int = 0) {
        guard index < viewModel.stepsViewModels.count else { return }
        let stepItemViewModel = viewModel.stepsViewModels[index]
        
        switch stepItemViewModel {
        case is StartNationalIdValidationViewModel:
            startNationalIdValidationViewController.delegate = self
            switchToViewController(startNationalIdValidationViewController)

        case is NationalIdFrontViewModel:
            nationalIdFrontValidationViewController.delegate = self
            switchToViewController(nationalIdFrontValidationViewController)

        case is NationalIdBackViewModel:
            nationalIdBackValidationViewController.delegate = self
            switchToViewController(nationalIdBackValidationViewController)
            
        case is IdReviewViewModel:
            idReviewViewController = .instance()
            idReviewViewController.delegate = self
            switchToViewController(idReviewViewController)
            
        case is StartFaceValidationViewModel:
            startFaceValidationViewController.delegate = self
            startFaceValidationViewController.stepIndex = index
            switchToViewController(startFaceValidationViewController)
            
        case is FaceValidationViewModel:
            if (viewModel.currentStepIndex == viewModel.face1ViewModel?.getStepIndex()) {
                face1ValidationViewController.delegate = self
                face1ValidationViewController.viewModel = stepItemViewModel as? FaceValidationViewModel
                switchToViewController(face1ValidationViewController)

            } else if (viewModel.currentStepIndex == viewModel.face2ViewModel?.getStepIndex()) {
                face2ValidationViewController.delegate = self
                face2ValidationViewController.viewModel = stepItemViewModel as? FaceValidationViewModel
                switchToViewController(face2ValidationViewController)

            } else if (viewModel.currentStepIndex == viewModel.face3ViewModel?.getStepIndex()) {
                face3ValidationViewController.delegate = self
                face3ValidationViewController.viewModel = stepItemViewModel as? FaceValidationViewModel
                switchToViewController(face3ValidationViewController)
            }
            
        default:
            break
        }
        
    }
    
    private func switchToViewController(_ viewController: UIViewController) {
        if let currentVC = currentChildViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        currentChildViewController = viewController
        
        addChild(viewController)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    private func postData() {
        Task {
            do {
                try await viewModel.postData()
                if let errorMessage = viewModel.validationErrorMessage {
                    loadingView.isHidden = false
                    loadingImageView.image = UIImage.gifImageWithName("person_error_final")
                    loadingMessageLabel.text = errorMessage
                    actionsView.isHidden = false
                    retryButton.isHidden = (CachedData.shared.noOfRetries == 0)
                    
                    return
                }
                
                closeSdkWithResult()
                
            } catch {
                debugPrint(error)
                closeSdkWithResult(errorMessage: "internet_connection_error".localized)
            }
        }
    }

    private func closeSdkWithResult(errorMessage: String? = nil) {
        self.dismiss(animated: true) { [self] in
            if (viewModel.isDigitalIdentityVerified) {
                delegate?.didValidateSuccessfully(transactionId: CachedData.shared.transactionId, userData: CachedData.shared.verifyBackResponse?.data)
            } else {
                delegate?.didFailToValidate(transactionId: CachedData.shared.transactionId, error: errorMessage ?? "div_failed".localized)
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
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

    @IBAction func retryButtonAction(_ sender: Any) {
        DatadogService.shared.info("User retried face scanning")
        DatadogService.shared.rumAddAction("retry_face_scanning")
        Task {
            CachedData.shared.noOfRetries = max(CachedData.shared.noOfRetries - 1, 0)
            didRetry(stepNumber: viewModel.faceStepIndex)
        }
    }

    @IBAction func closeButtonAction(_ sender: Any) {
        DatadogService.shared.info("User closed face error screen")
        DatadogService.shared.rumAddAction("close_face_error_screen")
        Task {
            didCancel()
        }
    }
}

extension ValidationMainViewController: ValidationMainViewControllerDelegate {
    func didBackToPreviousStep() {
        guard viewModel.currentStepIndex < viewModel.stepsViewModels.count else { return }
        let currentStepViewModel = viewModel.stepsViewModels[viewModel.currentStepIndex]
        
        // Special handling for IdReview - go back to NationalIdFront to redo the entire scan
        if currentStepViewModel is IdReviewViewModel {
            // Reset ID scan and go back to front ID scan
            viewModel.currentStepIndex = 1  // NationalIdFront step index
            nationalIdFrontValidationViewController = .instance()
            nationalIdBackValidationViewController = .instance()
            idReviewViewController = .instance()
            initViewsForStep(viewModel.currentStepIndex)
            return
        }
        
        viewModel.currentStepIndex -= 1
        if viewModel.currentStepIndex < 0 {
            viewModel.currentStepIndex = 0
        }
        
        initViewsForStep(viewModel.currentStepIndex)
    }
    
    func didFinishValidationStepNumber(_ stepNumber: Int) {
        guard stepNumber == viewModel.currentStepIndex else { return }

        let numOfSteps = viewModel.stepsViewModels.count

        if stepNumber + 1 == numOfSteps {
            guard !isPostingLiveness else { return }
            isPostingLiveness = true

            loadingView.isHidden = false
            loadingImageView.image = UIImage.gifImageWithName("person_scan_final")
            loadingMessageLabel.text = "processing_facial_recognition".localized
            postData()
            return
        }

        viewModel.currentStepIndex += 1
        initViewsForStep(stepNumber + 1)
    }
    
    func didRetry(stepNumber: Int) {
        isPostingLiveness = false
        viewModel.rerandomizeFaceInstructions()
        viewModel.validationErrorMessage = nil
        viewModel.currentStepIndex = stepNumber
        if (stepNumber == 0) {
            nationalIdFrontValidationViewController = .instance()
            nationalIdBackValidationViewController = .instance()
            idReviewViewController = .instance()
        }
        // Always recreate face view controllers on retry to reset camera and processing state
        // This is critical for liveness retry - old controllers have stale state (isProcessing = true)
        recreateFaceViewControllers()
        loadingView.isHidden = true
        actionsView.isHidden = true
        initViewsForStep(stepNumber)
    }
    
    /// Recreates all face view controller instances to ensure clean state on retry
    private func recreateFaceViewControllers() {
        // Create new instances of face view controllers
        // This resets isProcessing, camera session, and all captured data
        face1ValidationViewController = .instance()
        face2ValidationViewController = .instance()
        face3ValidationViewController = .instance()
    }
    
    func didCancel() {
        closeSdkWithResult(errorMessage: viewModel.validationErrorMessage)
    }
    
    func didFailWithError(_ error: String) {
        closeSdkWithResult(errorMessage: error)
    }
}
