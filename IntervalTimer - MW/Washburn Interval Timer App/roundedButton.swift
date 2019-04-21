//
//  roundedButton.swift
//  Washburn Interval Timer App
//
//  Created by Miranda Washburn on 11/11/18.
//  Copyright © 2018 Miranda Washburn. All rights reserved.
//

import UIKit

@IBDesignable class roundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    
    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
    }
}


