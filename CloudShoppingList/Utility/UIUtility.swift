//
//  UIUtility.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 14.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import Foundation
import UIKit

enum UIUtility{
    static func configureTextFields(textFields: [UITextField], borderColor: CGColor = UIColor.white.cgColor){
        for textField in textFields{
            // set bottom border
            let border = CALayer()
            let width = CGFloat(2.0)
            border.borderColor = borderColor
            border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
            border.borderWidth = width
            textField.layer.addSublayer(border)
            textField.layer.masksToBounds = true
        }
    }
}

extension UIViewController{
    @objc func hidingKeyboard(){
        self.view.frame.origin.y = 0
    }
}

extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedStringKey: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
}
