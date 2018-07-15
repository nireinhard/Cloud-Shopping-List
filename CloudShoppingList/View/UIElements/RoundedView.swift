//
//  RoundedView.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 14.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    
    @IBInspectable
    var cornerRounding: CGFloat = 0.0{
        didSet {
            layer.cornerRadius = cornerRounding
        }
    }
    
    override func awakeFromNib() {
        layer.masksToBounds = true
    }
    
}
