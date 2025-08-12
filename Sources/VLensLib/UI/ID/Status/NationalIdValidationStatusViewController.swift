//
//  NationalIdValidationStatusViewController.swift
//  VLensLib
//
//  Created by Mohamed Taher on 17/07/2025.
//

import UIKit

class NationalIdValidationStatusViewController: UIViewController {

    static func instance() -> NationalIdValidationStatusViewController {
        let viewController = NationalIdValidationStatusViewController()
        return viewController
    }
    
    var delegate: ValidationMainViewControllerDelegate? = nil
    
    public init() {
        super.init(nibName: "NationalIdValidationStatusViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Just to confirm it loaded
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
