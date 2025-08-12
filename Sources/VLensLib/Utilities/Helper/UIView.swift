//
//  UIView.swift
//  MallMe
//
//  Created by Mohamed Taher on 2/24/18.
//  Copyright © 2018 Silver Key. All rights reserved.
//

import UIKit

@IBDesignable extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    /* The color of the shadow. Defaults to opaque black. Colors created
     * from patterns are currently NOT supported. Animatable. */
    @IBInspectable var shadowColor: UIColor? {
        set {
            layer.shadowColor = newValue!.cgColor
        }
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var maskToBound: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    func traverseSubviewForViewOfKind(kind: AnyClass) -> UIView? {
        var matchingView: UIView?
        
        for aSubview in subviews {
            if type(of: aSubview) == kind {
                matchingView = aSubview
                return matchingView
            } else {
                if let matchingView = aSubview.traverseSubviewForViewOfKind(kind: kind) {
                    return matchingView
                }
            }
        }
        
        return matchingView
    }
    
    func showSpinner(isWhite: Bool = true, completion: @escaping ((_ viewSpinner: UIView) -> Void)){
        DispatchQueue.main.async {
            
            let spinnerView = UIView.init(frame: self.bounds)
            let ai = UIActivityIndicatorView.init(style: .whiteLarge)
            if (isWhite) {
                spinnerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            } else {
                ai.color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            }
            ai.startAnimating()
            ai.center = spinnerView.center
            
            //DispatchQueue.main.async {
                spinnerView.addSubview(ai)
                self.addSubview(spinnerView)
            //}
            
            let viewSpinner = spinnerView
            completion(viewSpinner)
        }
    }
    
    func removeSpinner(viewSpinner: UIView) {
        DispatchQueue.main.async {
            viewSpinner.removeFromSuperview()
        }
    }
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      self.layer.mask = mask
    }

    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi)
        rotation.duration = 0.5
        rotation.isCumulative = false
        rotation.repeatCount = 0
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func showAsNavigation() {
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.frame = CGRect(x: self.frame.size.width, y: self.frame.minY,width: self.frame.size.width , height: self.frame.size.height)
        }, completion: { (finished: Bool) -> Void in
            self.backgroundColor = UIColor.clear
        })
    }
    
    func backAsNavigation(completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.frame = CGRect(x: -1 * self.frame.size.width, y: self.frame.minY, width: self.frame.size.width , height: self.frame.size.height)
        }, completion: { (finished: Bool) -> Void in
            self.backgroundColor = UIColor.clear
            completion()
        })
    }
}

extension UINib {
    func instantiate() -> Any? {
        return self.instantiate(withOwner: nil, options: nil).first
    }
}

extension UIView {

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    static func instantiate(autolayout: Bool = true) -> Self {
        // generic helper function
        func instantiateUsingNib<T: UIView>(autolayout: Bool) -> T {
            let view = self.nib.instantiate() as! T
            view.translatesAutoresizingMaskIntoConstraints = !autolayout
            return view
        }
        return instantiateUsingNib(autolayout: autolayout)
    }
}

extension UIView {
    func getImageFromCurrentContext(bounds: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds?.size ?? self.bounds.size, false, 0.0)
        self.drawHierarchy(in: bounds ?? self.bounds, afterScreenUpdates: true)

        guard let currentImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        UIGraphicsEndImageContext()

        return currentImage
    }
}
