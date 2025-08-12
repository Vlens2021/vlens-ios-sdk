//
//  Utils.swift
//  MallMe
//
//  Created by Inno Labs on 3/1/18.
//  Copyright © 2018 Silver Key. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

@MainActor 
class Utils{
    
    private static var alertView: UIAlertController?
    
    public static func flashNoActionAlert(sender: UIViewController, title alertTitle: String, message alertMessage: String?, _ onComplete: (() -> Void)? = nil){
        let alertView = UIAlertController(title: alertTitle, message: alertMessage , preferredStyle: UIAlertController.Style.alert);
        
        let titleFont = [NSAttributedString.Key.font: UIFont(name: Constants.Font.medium, size: 18.0) ?? .systemFont(ofSize: 16)]
        let messageFont = [NSAttributedString.Key.font: UIFont(name: Constants.Font.regular, size: 18.0) ?? .systemFont(ofSize: 16)]

        let titleAttrString = NSMutableAttributedString(string: alertTitle, attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: alertMessage ?? "", attributes: messageFont)

        alertView.setValue(titleAttrString, forKey: "attributedTitle")
        alertView.setValue(messageAttrString, forKey: "attributedMessage")
        
        sender.present(alertView, animated: true, completion:nil)
        let when = DispatchTime.now() + 1.5   //seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertView.dismiss(animated: true, completion: nil)
            if (onComplete != nil) {
                onComplete!()
            }
        }
    }
    
    public static func fixedNoActionAlert(sender: UIViewController, title alertTitle: String, message alertMessage: String?){
//        alertView = UIAlertController(title: alertTitle, message: alertMessage , preferredStyle: UIAlertController.Style.alert);
//        sender.present(alertView!, animated: true, completion:{
//            alertView?.view.superview?.isUserInteractionEnabled = true
//            alertView?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
//        })
        
        fixedNoActionAlertWithCloseAction(sender: sender, title: alertTitle, message: alertMessage)
    }
    
    public static func fixedNoActionAlert(sender: UIViewController, title alertTitle: String, _ onComplete: (() -> Void)? = nil){
        fixedNoActionAlertWithCloseAction(sender: sender, title: alertTitle, onComplete)
    }
    
    public static func fixedNoActionAlertWithCloseAction(sender: UIViewController, title alertTitle: String, message alertMessage: String? = nil, _ onComplete: (() -> Void)? = nil){
        alertView = UIAlertController(title: alertTitle, message: alertMessage , preferredStyle: UIAlertController.Style.alert);
                
        if let mediumFont = UIFont(name: Constants.Font.medium, size: 18.0) {
            let titleFont = [NSAttributedString.Key.font: mediumFont]
            let titleAttrString = NSMutableAttributedString(string: alertTitle, attributes: titleFont)
            alertView?.setValue(titleAttrString, forKey: "attributedTitle")
        }
        
        if let regularFont = UIFont(name: Constants.Font.regular, size: 18.0) {
            let messageFont = [NSAttributedString.Key.font: regularFont]
            let messageAttrString = NSMutableAttributedString(string: alertMessage ?? "", attributes: messageFont)
            alertView?.setValue(messageAttrString, forKey: "attributedMessage")
        }
        
        let action = UIAlertAction(title: "close".localized, style: .default) { _ in
            alertView?.dismiss(animated: true, completion: nil)
            if (onComplete != nil) {
                onComplete!()
            }
        }
        action.setValue(UIColor(named: Constants.Colors.accent), forKey: "titleTextColor")
        alertView?.addAction(action)
        
        sender.present(alertView!, animated: true, completion:{
            alertView?.view.superview?.isUserInteractionEnabled = true
            alertView?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    public static func fixedNoActionAlertWithYesAndNoActions(sender: UIViewController, title alertTitle: String, message alertMessage: String? = nil, image imgTitle: UIImage? = nil, completion: @escaping ((_ isYes: Bool) -> Void)){
        alertView = UIAlertController(title: alertTitle, message: alertMessage , preferredStyle: UIAlertController.Style.alert);
                
        let titleFont = [NSAttributedString.Key.font: UIFont(name: Constants.Font.medium, size: 18.0) ?? .systemFont(ofSize: 16)]
        let messageFont = [NSAttributedString.Key.font: UIFont(name: Constants.Font.regular, size: 18.0) ?? .systemFont(ofSize: 16)]

        var _alertTitle = alertTitle
        if (imgTitle != nil) {
            _alertTitle = "\n\n" + alertTitle
            
            let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 30, width: 250, height: 40))
            imgViewTitle.contentMode = .scaleAspectFit
            imgViewTitle.image = imgTitle
            alertView?.view.addSubview(imgViewTitle)
        }
        let titleAttrString = NSMutableAttributedString(string: _alertTitle, attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: alertMessage ?? "", attributes: messageFont)

        alertView?.setValue(titleAttrString, forKey: "attributedTitle")
        alertView?.setValue(messageAttrString, forKey: "attributedMessage")

        let noAction = UIAlertAction(title: "dialog_cancel".localized, style: .cancel) { _ in
            completion(false)
            alertView?.dismiss(animated: true, completion: nil)
        }
        
        noAction.setValue(UIColor(named: Constants.Colors.accent), forKey: "titleTextColor")
        alertView?.addAction(noAction)
        
        let yesAction = UIAlertAction(title: "dialog_ok".localized, style: .default) { _ in
            completion(true)
            alertView?.dismiss(animated: true, completion: nil)
        }
        
        yesAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertView?.addAction(yesAction)
        

        
        sender.present(alertView!, animated: true, completion:{
//            alertView?.view.superview?.isUserInteractionEnabled = true
//            alertView?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }

    public static func fixedNoActionAlertWithDoneAction(sender: UIViewController, title alertTitle: String, message alertMessage: String? = nil, completion: @escaping (() -> Void)){
        alertView = UIAlertController(title: alertTitle, message: alertMessage , preferredStyle: UIAlertController.Style.alert);

        alertView?.addAction(UIAlertAction(title: "done".localized, style: .default) { _ in
            alertView?.dismiss(animated: true, completion: nil)
            completion()
        })

        sender.present(alertView!, animated: true, completion:{
            alertView?.view.superview?.isUserInteractionEnabled = true
            alertView?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    public static func oneActionAlert(sender: UIViewController, title alertTitle: String, message alertMessage: String?, actionName: String, hasCancelAction: Bool = false, action: @escaping (UIAlertAction) -> Void) {
        
        let titleFont = [NSAttributedString.Key.font: UIFont(name: Constants.Font.medium, size: 18.0) ?? .systemFont(ofSize: 16)]
        let messageFont = [NSAttributedString.Key.font: UIFont(name: Constants.Font.regular, size: 18.0) ?? .systemFont(ofSize: 16)]
        
        let titleAttrString = NSMutableAttributedString(string: alertTitle, attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: alertMessage ?? "", attributes: messageFont)
        
        alertView = UIAlertController(title: alertTitle, message: alertMessage , preferredStyle: UIAlertController.Style.alert);
        
        alertView?.setValue(titleAttrString, forKey: "attributedTitle")
        alertView?.setValue(messageAttrString, forKey: "attributedMessage")
        
        if (hasCancelAction) {
            alertView?.addAction(UIAlertAction(title: "cancel".localized, style: .default) { _ in
                alertView?.dismiss(animated: true, completion: nil)
            })
        }
        
        alertView?.addAction(UIAlertAction(title: actionName, style: .default, handler: action))
        
        sender.present(alertView!, animated: true, completion:{
            alertView?.view.superview?.isUserInteractionEnabled = true
            alertView?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    public static func twoActionAlert(sender: UIViewController, title alertTitle: String, message alertMessage: String?, actionName: String, hasCancelAction: Bool = false, cancelActionName: String?, action: @escaping (UIAlertAction) -> Void, cancelAction: @escaping () -> Void) {
        
        let titleFont = [NSAttributedString.Key.font: UIFont(name: Constants.Font.medium, size: 18.0) ?? .systemFont(ofSize: 16)]
        let messageFont = [NSAttributedString.Key.font: UIFont(name: Constants.Font.regular, size: 18.0) ?? .systemFont(ofSize: 16)]
        
        let titleAttrString = NSMutableAttributedString(string: alertTitle, attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: alertMessage ?? "", attributes: messageFont)
        
        alertView = UIAlertController(title: alertTitle, message: alertMessage , preferredStyle: UIAlertController.Style.alert);
              
        alertView?.setValue(titleAttrString, forKey: "attributedTitle")
        alertView?.setValue(messageAttrString, forKey: "attributedMessage")
        
        if (hasCancelAction) {
            alertView?.addAction(UIAlertAction(title: cancelActionName ?? "cancel".localized, style: .default) { _ in
                alertView?.dismiss(animated: true, completion: nil)
                cancelAction()
            })
        }
       
        alertView?.addAction(UIAlertAction(title: actionName, style: UIAlertAction.Style.default, handler: action))

        sender.present(alertView!, animated: true, completion:{
            alertView?.view.superview?.isUserInteractionEnabled = true
            alertView?.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc private static func alertControllerBackgroundTapped() {
        Utils.alertView?.dismiss(animated: true, completion: nil)
    }
    
    public static func fixedAlertWithOkAction(sender: UIViewController, title alertTitle: String, message alertMessage: String? = nil, completion: @escaping (() -> Void)){
        alertView = UIAlertController(title: alertTitle, message: alertMessage , preferredStyle: UIAlertController.Style.alert);

        alertView?.addAction(UIAlertAction(title: "okay".localized, style: .default) { _ in
            alertView?.dismiss(animated: true, completion: nil)
            completion()
        })

    
        sender.present(alertView!, animated: true)
    }
    
    public static func openLink(link: String) {
        guard let url = URL(string: link) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    static func toDate(str: String?) -> Date? {
        if str == nil { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: str!) //according to date format your date string
        return date
    }
    
    static func openAppUrl(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    static func getValidationError(statusMassage: String?, errors: [String : [String]?]?) -> String{
        var result = ""
        if (errors == nil || errors?.count == 0) {
            if (statusMassage == nil || statusMassage == "") {
                return "Failed. Try again"
            } else {
                return statusMassage ?? "Failed. Try again"
            }
        }
        
        for (_, massages) in errors! {
            for msg in massages ?? [] {
                if (result != "") {
                    result += "\n"
                }
                result += msg
            }
        }
        
        if (result == "") {
            return statusMassage ?? "Failed. Try again"
        }
        return result
    }
    
//    static func generateQRCode(from string: String) -> UIImage? {
//        let data = string.data(using: String.Encoding.ascii)
//
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//            let transform = CGAffineTransform(scaleX: 3, y: 3)
//
//            if let output = filter.outputImage?.transformed(by: transform) {
//                return UIImage(ciImage: output)
//            }
//        }
//
//        return nil
//    }
    
    static func createQRFromString(str: String) -> UIImage? {
        let stringData = str.data(using: .utf8)

        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(stringData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")

        if let outputImage = filter?.outputImage {
            let image = UIImage(ciImage: outputImage.transformed(by: CGAffineTransform(scaleX: 15, y: 15)), scale: 0.5, orientation: .up)
            return image
        }
        
        return nil
    }
    
    static func compressBase64Image(_ base64String: String, maxSizeMB: Int = 3) -> String? {
        let maxSizeBytes = maxSizeMB * 1024 * 1024  // Convert MB to Bytes
        
        // Convert Base64 to Data
        guard let imageData = Data(base64Encoded: base64String) else {
            print("Invalid Base64 string")
            return nil
        }
        
        // Convert Data to UIImage
        guard let image = UIImage(data: imageData) else {
            print("Invalid Image Data")
            return nil
        }
        
        var compressionQuality: CGFloat = 1.0
        var compressedData = image.jpegData(compressionQuality: compressionQuality)
        
        // Reduce quality until it fits within maxSizeBytes
        while let data = compressedData, data.count > maxSizeBytes, compressionQuality > 0.1 {
            compressionQuality -= 0.1
            compressedData = image.jpegData(compressionQuality: compressionQuality)
        }
        
        guard let finalData = compressedData else {
            print("Compression failed")
            return nil
        }
        
        // Convert back to Base64
        return finalData.base64EncodedString()
    }

}
