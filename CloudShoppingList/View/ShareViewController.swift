//
//  ShareViewController.swift
//  CloudShoppingList
//
//  Created by Niklas Reinhard on 15.07.18.
//  Copyright © 2018 Niklas Reinhard. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    @IBOutlet weak var shareLinkLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateShareLink()
    }
    
    private func generateShareLink(){
        var base = "fbase.io/98543i"
        shareLinkLabel.text = base
    }


}
