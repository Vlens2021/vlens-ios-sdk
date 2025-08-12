//
//  Localization.swift
//
//
//  Created by Mohamed Taher on 30/11/2023.
//

import Foundation
import UIKit

let LOCALIZATION_TABLE_NAME = "Localizable"

@MainActor
extension String {

    func localization(languageCode: String) -> String {
//        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        let path = Bundle.module.path(forResource: languageCode, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: LOCALIZATION_TABLE_NAME, bundle: bundle!, value: "", comment: "")
    }
    
    var localized: String {
        let languageCode = Localization.instance.appleLanguageCode
        return localization(languageCode: languageCode)
    }
    
    func localizeName(nameAr: String?) -> String {
        let languageCode = Localization.instance.appleLanguageCode
        if (languageCode == AppleLanguageCode.english) {
            if (self.isEmpty) {
                return nameAr ?? ""
            } else {
                return self
            }
        } else {
            if (nameAr?.isEmpty == true) {
                return self
            } else {
                return nameAr ?? self
            }
        }
    }
}

@MainActor
protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}
//
//extension UITextView: XIBLocalizable {
//    @IBInspectable var xibLocKey: String? {
//        get { return nil }
//        set(key) {
//            self.text = key?.localized
//        }
//    }
//}
//

@MainActor
extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            if Localization.instance.languageDirection == .RTL {
                self.semanticContentAttribute = .forceRightToLeft
                if (self.textAlignment == .left) {
                    self.textAlignment = .right
                } else if (self.textAlignment == .right) {
                    self.textAlignment = .left
                }
                
            } else {
                self.semanticContentAttribute = .forceLeftToRight
            }
            text = key?.localized
        }
    }
}
//
//extension UITextField: XIBLocalizable {
//    @IBInspectable var xibLocKey: String? {
//        get { return nil }
//        set(key) {
//            if Localization.instance.languageDirection == .RTL {
//                self.semanticContentAttribute = .forceRightToLeft
//                self.textAlignment = .right
//            } else {
//                self.semanticContentAttribute = .forceLeftToRight
//                self.textAlignment = .left
//            }
//            self.placeholder = key?.localized
//        }
//    }
//}
//

@MainActor
extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
//            if (self.contentHorizontalAlignment != .center) {
//                if Localization.instance.languageDirection == .RTL {
//                    self.semanticContentAttribute = .forceRightToLeft
//                    self.contentHorizontalAlignment = .right
//                } else {
//                    self.semanticContentAttribute = .forceLeftToRight
//                    self.contentHorizontalAlignment = .left
//                }
//            }
            setTitle(key?.localized, for: .normal)
        }
    }
    @IBInspectable var imgLocalized: String? {
        get { return nil }
        set(key) {
            guard let imgKey = key?.localized else {
                return
            }
            self.setImage(UIImage(named: imgKey), for: .normal)
        }
    }
}
//
//extension UIBarButtonItem: XIBLocalizable {
//    @IBInspectable var xibLocKey: String? {
//        get { return nil }
//        set(key) {
//            self.title = key?.localized
//        }
//    }
////    @IBInspectable var ImageLocalized: String? {
////        get { return nil }
////        set(key) {
////            guard let key = key else {
////                return
////            }
////            self.image = UIImage(named: key.localized)
////            //            self.title = key?.localized
////        }
////    }
//}
//
//extension UISearchBar: XIBLocalizable {
//    @IBInspectable var xibLocKey: String? {
//        get { return nil }
//        set(key) {
//            self.placeholder = key?.localized
//        }
//    }
//}
//
//extension UITabBarItem: XIBLocalizable {
//    @IBInspectable var xibLocKey: String? {
//        get { return nil }
//        set(key) {
//            self.title = key?.localized
//        }
//    }
////    @IBInspectable var ImageLocalized: String? {
////        get { return nil }
////        set(key) {
////            guard let key = key else {
////                return
////            }
////            self.image = UIImage(named: key.localized)
////            //            self.title = key?.localized
////        }
////    }
//}
//
//extension UIImageView: XIBLocalizable {
//    var xibLocKey: String? {
//        get {
//            return nil
//        }
//        set {
//            return
//        }
//    }
//    
//    @IBInspectable var imgLocalized: String? {
//        get { return nil }
//        set(key) {
//            guard let imgKey = key?.localized else {
//                return
//            }
//            self.image = UIImage(named: imgKey)
//        }
//    }
//}
//
//extension NSAttributedString {
//
//    convenience init?(withLocalizedHTMLString: String) {
//
//        guard let stringData = withLocalizedHTMLString.data(using: String.Encoding.utf8) else {
//            return nil
//        }
//
//        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
//            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html as Any,
//            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue,
//            
//        ]
//
//        try? self.init(data: stringData, options: options, documentAttributes: nil)
//    }
//}
//
//extension UIViewController {
//    
////    func restartApp() {
////        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
////            return
////        }
////
////        guard let window = windowScene.windows.first else {
////            return
////        }
////
////        let viewController = SplashViewController.instance()
////        viewController.view.layoutIfNeeded()
////
////        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
////            window.rootViewController = viewController
////        })
////    }
//    
////    func changeLaunguage(launguage: Language) {
////        Localization.instance.changeLaunguange(language: launguage)
////        restartApp()
////    }
//
////    func changeLaunguage() {
////        let languageCode = AppUserDefaults.shared.getCurrentLaungaugeCode()
////        switch languageCode {
////            case Language.arabic.rawValue:
////                changeLaunguage(launguage: Language.english)
////                break
////
////            default:
////                changeLaunguage(launguage: Language.arabic)
////        }
////    }
//}
//
enum LanguageDirection {
    case RTL
    case LTR
}

struct AppleLanguageCode {
    static let english = "en"
    static let arabic = "ar"
}

enum Language: String {
    case english = "en"
    case arabic = "ar"
}

@MainActor
class Localization {
    
    static var instance = Localization()
    
    private let APPLE_LAUNGUAGE_KEY = "AppleLanguages"
    private let LAUNGUAGE_CODE_KEY = "languageCode"

    fileprivate var languageDirection: LanguageDirection
    var appleLanguageCode: String

    fileprivate var semantic: UISemanticContentAttribute {
        switch languageDirection {
        case .LTR:
            return .forceLeftToRight
        case .RTL:
            return .forceRightToLeft
        }
    }
    
    private init() {
        
//        let languageCode = AppleLanguageCode.english // TODO: get from user defaults
        let languageCode = CachedData.shared.language
        
        switch languageCode {
            case Language.arabic.rawValue:
                appleLanguageCode = AppleLanguageCode.arabic
                languageDirection = .RTL
                break
            
            default:
                appleLanguageCode = AppleLanguageCode.english
                languageDirection = .LTR
                
        }
    }
    
}
