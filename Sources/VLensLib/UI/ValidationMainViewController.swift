//
//  ValidationMainViewController.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import UIKit
internal import RxSwift
internal import RxCocoa

protocol ValidationMainViewControllerDelegate {
    func didBackToPreviousStep() async
    func didFinishValidationStepNumber(_ stepNumber: Int) async
    func didRetry(stepNumber: Int) async
    func didCancel() async
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
//    @IBOutlet weak var loadingTitleLabel: UILabel!
    @IBOutlet weak var loadingMessageLabel: UILabel!
    
    @IBOutlet weak var actionsView: UIStackView!
    @IBOutlet weak var retryButton: UIButton!
    
    var delegate: VLensDelegate? = nil
    
    private let startNationalIdValidationViewController      : StartNationalIdValidationViewController  = .instance()
    private var nationalIdFrontValidationViewController      : NationalIdFrontViewController            = .instance()
    private var nationalIdBackValidationViewController       : NationalIdBackViewController             = .instance()
    private let startFaceValidationViewController            : StartFaceValidationViewController        = .instance()
    private let face1ValidationViewController                : FaceViewController                       = .instance()
    private let face2ValidationViewController                : FaceViewController                       = .instance()
    private let face3ValidationViewController                : FaceViewController                       = .instance()
    
    private var currentChildViewController: UIViewController? = nil

    private let viewModel = ValidationMainViewModel()
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: "ValidationMainViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        viewModel.initData()
        
        initViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initViews()
    }
    
    
    private func initViews() {
        initViewsForStep(0)
        loadingView.isHidden = true
        loadingImageView.image = UIImage.gifImageWithName("person_scan_final")
        actionsView.isHidden = true
        loadingMessageLabel.text = "processing_your_id".localized
    }
    
    private func initViewsForStep(_ index: Int = 0) {
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
            
        case is StartFaceValidationViewModel:
            startFaceValidationViewController.delegate = self
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
                await try viewModel.postData()
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
                closeSdkWithResult()
            }
        }
    }

    private func closeSdkWithResult(errorMessage: String? = nil) {
        self.dismiss(animated: true) { [self] in
            if (viewModel.isDigitalIdentityVerified) {
                delegate?.didValidateSuccessfully(transactionId: CachedData.shared.transactionId, userData: CachedData.shared.verifyBackResponse?.data)
            } else {
                delegate?.didFailToValidate(transactionId: CachedData.shared.transactionId, error: errorMessage ?? "N/A")
            }
        }
    }
    
    @IBAction func retryButtonAction(_ sender: Any) {
        Task {
            CachedData.shared.noOfRetries = max(CachedData.shared.noOfRetries - 1, 0)
            await didRetry(stepNumber: viewModel.faceStepIndex)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        Task {
            await didCancel()
        }
    }
}

extension ValidationMainViewController: ValidationMainViewControllerDelegate {
    func didBackToPreviousStep() {
        viewModel.currentStepIndex -= 1
        if viewModel.currentStepIndex < 0 {
            viewModel.currentStepIndex = 0
        }
        
        initViewsForStep(viewModel.currentStepIndex)
    }
    
    func didFinishValidationStepNumber(_ stepNumber: Int) {
        DispatchQueue.main.async { [self] in
            
            let numOfSteps = viewModel.stepsViewModels.count
            
            let _stepNumber = max(stepNumber, viewModel.currentStepIndex)
            
            if (_stepNumber + 1 == numOfSteps) {
                
                loadingView.isHidden = false
//                loadingTitleLabel.text = "verifying_your_identity".localized
                loadingImageView.image = UIImage.gifImageWithName("person_scan_final")
                loadingMessageLabel.text = "processing_facial_recognition".localized
                postData()
                return
            }
            
            viewModel.currentStepIndex += 1
            initViewsForStep(_stepNumber + 1)
        }
    }
    
    func didRetry(stepNumber: Int) {
        viewModel.currentStepIndex = stepNumber
        if (stepNumber == 0) {
            nationalIdFrontValidationViewController = .instance()
            nationalIdBackValidationViewController = .instance()
        }
        
        initViewsForStep(stepNumber)
    }
    
    func didCancel() {
        closeSdkWithResult(errorMessage: "USER_TAPPED_CANCEL")
    }
}
