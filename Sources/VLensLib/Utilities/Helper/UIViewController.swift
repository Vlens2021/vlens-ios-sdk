//
//  UIViewController.swift
//  MallMe
//
//  Created by Mohamed Taher on 2/13/18.
//  Copyright © 2018 Silver Key. All rights reserved.
//

import UIKit

//var vSpinner : UIView?

@MainActor
extension UIViewController {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
//        navigationController?.view.semanticContentAttribute = .forceRightToLeft
//        navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
    }
    
    // hide & show navigation bar
    func hideNavigationBar(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func showNavigationBar(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.setValue(UIColor.white, forKey: "foregroundColor")
        }
        changeNavigationBarColor()
    }
    
    func changeNavigationBarColor() {
        
        resetStatusBarBackgroundColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]

        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = UIColor(named: "main_color")
        navigationBarAppearace.barTintColor = UIColor(named: "main_color")
    }
    
    func changeNavigationBarColorToNightMode() {
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = UIColor.black
        navigationBarAppearace.barTintColor = UIColor.black
    }
    
    // Finish Editing
    func addFinishEditingStyle() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissEditing() {
        view.endEditing(true)
    }
    
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = style == .lightContent ? UIColor.black : .white
            statusBar.setValue(style == .lightContent ? UIColor.white : .black, forKey: "foregroundColor")
        }
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard  let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = color
    }
    
    func resetStatusBarBackgroundColor() {
        guard  let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView else {
            return
        }
        statusBar.backgroundColor = nil
    }
    
    //back
    func back(animated: Bool = true, completion: @escaping (() -> Void) = {}) {
        
        //Handle back in notidication view controllers
//        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
//        let viewController = appDelegate.window?.rootViewController
//        if (viewController == self) {
//            let defaultViewController = SplashViewController.instance()
//            defaultViewController.modalPresentationStyle = .fullScreen
//            present(defaultViewController, animated: false, completion: nil)
//            return
//        }
        
        if let nav = self.navigationController {
            nav.popViewController(animated: animated)
        } else {
            self.dismiss(animated: animated, completion: completion)
        }
    }
    
    func showSpinner(onView : UIView, isWhite: Bool = true, completion: @escaping ((_ vSpinner: UIView) -> Void)) {
//        DispatchQueue.main.async {
//            if (vSpinner != nil) {
//                self.removeSpinner(vSpinner: vSpinner)
//            }
            
            let spinnerView = UIView.init(frame: onView.bounds)
            let ai = UIActivityIndicatorView.init(style: .large)
            if (isWhite) {
                spinnerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            } else {
                ai.color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            }
            ai.startAnimating()
            ai.center = spinnerView.center
            
            //DispatchQueue.main.async {
                spinnerView.addSubview(ai)
                onView.addSubview(spinnerView)
            //}
            
            //vSpinner = spinnerView
            completion(spinnerView)
//        }
    }
    
    func removeSpinner(vSpinner : UIView) {
        DispatchQueue.main.async {
            vSpinner.removeFromSuperview()
        }
    }
    
    func showSpinnerWithTitle(onView : UIView, isWhite: Bool = true, completion: @escaping ((_ vSpinner: UIView, _ vLabel: UILabel) -> Void)) {
        DispatchQueue.main.async {
            let spinnerView = UIView.init(frame: onView.bounds)
            let ai = UIActivityIndicatorView.init(style: .large)
            if (isWhite) {
                spinnerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            } else {
                ai.color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            }
            
            ai.startAnimating()
            ai.center = spinnerView.center
            
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
            
            let titleLabel = UILabel()
//            titleLabel.font = UIFont(name: AppConstants.Font.medium, size: 18.0)
            titleLabel.textColor = .darkGray
            titleLabel.text = "Loading"
            titleLabel.textAlignment = .center
            titleLabel.frame = CGRect(x: 10, y: 60, width: onView.bounds.width - 20, height: onView.bounds.height - 60)
            onView.addSubview(titleLabel)
            
            completion(spinnerView, titleLabel)
        }
    }
    
    func removeSpinnerWithTitle(vSpinner : UIView, titleLabel: UILabel) {
        DispatchQueue.main.async {
            titleLabel.removeFromSuperview()
            vSpinner.removeFromSuperview()
        }
    }
    
    func openLink(link: String) {
        guard let appURL = URL(string: link) else { return }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(appURL)
            }
        }
    }
    
    func mailTo(email: String) {
        let appURL = URL(string: "mailto:\(email)")!

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    }
    
    func presentAsNavigation(_ viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewController, animated: false, completion: nil)
    }
}

extension UITabBarController {
    open override var childForStatusBarStyle: UIViewController? {
        return selectedViewController?.childForStatusBarStyle ?? selectedViewController
    }
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController?.childForStatusBarStyle ?? topViewController
    }
}
