//
//  ButtonExtension.swift
//  Flag
//
//  Created by marky RE on 11/24/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import Foundation
import UIKit
extension UIButton {
    @IBInspectable var cornerRadius:CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
             layer.cornerRadius = newValue
        }
    }
}
