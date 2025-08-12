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
    
    public init() {
        super.init(nibName: "StartNationalIdValidationViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Just to confirm it loaded
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
