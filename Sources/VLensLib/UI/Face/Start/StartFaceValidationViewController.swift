//
//  StartFaceValidationViewController.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import UIKit

class StartFaceValidationViewController: UIViewController {

    static func instance() -> StartFaceValidationViewController {
        let viewController = StartFaceValidationViewController()
        return viewController
    }
    
    public init() {
        super.init(nibName: "StartFaceValidationViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var delegate: ValidationMainViewControllerDelegate? = nil
    var stepIndex: Int = 0
    
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var faceVectorImageView: UIImageView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        DatadogService.shared.rumStartView(key: "start_face_validation", name: "Start Face Validation Screen")
        DatadogService.shared.info("Start Face Validation screen displayed")
        let colors = CachedData.shared.colors.current(for: traitCollection)
        view.backgroundColor = colors.backgroundColor
        titleLabel.textColor = colors.primaryColor
        startButton.backgroundColor = colors.accentColor

        // Set custom client logo if provided
        if let clientLogo = CachedData.shared.clientLogoImage {
            logoImageView?.image = clientLogo
            logoImageView?.contentMode = .scaleAspectFit
        }

        addGifBackground(to: faceVectorImageView)
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

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DatadogService.shared.rumStopView(key: "start_face_validation")
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        DatadogService.shared.info("Start Face Validation tapped")
        DatadogService.shared.rumAddAction("start_face_validation_tap")
        Task {
            await delegate?.didFinishValidationStepNumber(stepIndex)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
