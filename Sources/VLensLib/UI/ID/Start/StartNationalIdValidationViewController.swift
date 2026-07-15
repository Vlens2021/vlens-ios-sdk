//
//  StartNationalIdValidationViewController.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import UIKit

class StartNationalIdValidationViewController: UIViewController {

    static func instance() -> StartNationalIdValidationViewController {
        let viewController = StartNationalIdValidationViewController()
        return viewController
    }
    
    var delegate: ValidationMainViewControllerDelegate? = nil

    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var idVectorImageView: UIImageView!

    public init() {
        super.init(nibName: "StartNationalIdValidationViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let colors = CachedData.shared.colors.current(for: traitCollection)
        view.backgroundColor = colors.backgroundColor
        titleLabel.textColor = colors.primaryColor
        scanButton.backgroundColor = colors.accentColor

        // Set custom client logo if provided
        if let clientLogo = CachedData.shared.clientLogoImage {
            logoImageView?.image = clientLogo
            logoImageView?.contentMode = .scaleAspectFit
        }

        addGifBackground(to: idVectorImageView)
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

    @IBAction func nextButtonAction(_ sender: Any) {
        Task {
            await delegate?.didFinishValidationStepNumber(0)
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
