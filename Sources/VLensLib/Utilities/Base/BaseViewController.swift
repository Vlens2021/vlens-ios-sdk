//
//  BaseViewController.swift
//  bdc
//
//  Created by Mohamed Taher on 30/11/2023.
//

import UIKit

public class BaseViewController: UIViewController {

    private var spinnerView = UIView()
    private var hasActiveSpinner = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()

//        overrideUserInterfaceStyle = (CachedData.shared.themeId == AppConstants.Theme.dark) ? .dark : .light
//        UIView.appearance().semanticContentAttribute = (CachedData.shared.languageId == AppConstants.Language.arabic) ? .forceRightToLeft : .forceLeftToRight
    }

    func showSpinner(isWhite: Bool = true) {
        if (hasActiveSpinner == true) {
            return
        }
        
        hasActiveSpinner = true
        showSpinner(onView: self.view) { vSpinner in
            self.spinnerView = vSpinner
        }
    }
    
    func removeSpinner() {
        hasActiveSpinner = false
        removeSpinner(vSpinner: self.spinnerView)
    }
    
    func popupErrorMessage(message: String?) {
        hasActiveSpinner = false
        removeSpinner(vSpinner: self.spinnerView)
        //Utils.fixedNoActionAlert(sender: self, title: message ?? "error".localized)
    }
    
    func navigateToRootViewAndSelectTab(tabIndex: Int) {
        // Ensure the tab bar controller exists
        guard let tabBarController = self.tabBarController else {
            return
        }
        
        // Ensure the tab index is within bounds
        guard tabIndex < tabBarController.viewControllers?.count ?? 0 else {
            return
        }
        
        // Pop to the root view controller of the current navigation controller
        if let navigationController = tabBarController.selectedViewController as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
        
        // Select the specific tab
        tabBarController.selectedIndex = tabIndex
        
        // Pop to the root view controller of the newly selected tab's navigation controller
        if let navigationController = tabBarController.viewControllers?[tabIndex] as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }
}

