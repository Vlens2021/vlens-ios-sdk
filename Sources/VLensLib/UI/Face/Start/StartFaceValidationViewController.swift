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

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
