//
//  TextfieldExtension.swift
//  Flag
//
//  Created by marky RE on 12/4/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

extension UITextField {
    func addUnderline() {
        
        let border = CALayer()
        let borderWidth = CGFloat(1.5)
        border.borderColor = UIColor.stellaPurple().cgColor
        border.frame = CGRect(x:0, y:self.frame.size.height - borderWidth, width:self.frame.size.width, height:self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
