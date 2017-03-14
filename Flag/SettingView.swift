//
//  SettingView.swift
//  Flag
//
//  Created by marky RE on 12/3/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class SettingView: UIView {
    @IBOutlet weak var editName:UIButton!
    @IBOutlet weak var block:UIButton!
    @IBOutlet weak var cancel:UIButton!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var subname:UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 10.0
        let cornerRadius:CGFloat = 20.0
        
        var str = NSMutableAttributedString(string: "Block user", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 15.0)!])
        block.setAttributedTitle(str, for: .normal)
        block.layer.cornerRadius = cornerRadius
        block.backgroundColor = UIColor.stellaPurple()
        block.tintColor = UIColor.white
        str = NSMutableAttributedString(string: "Edit name", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 15.0)!])
        
        editName.setAttributedTitle(str, for: .normal)
        editName.tintColor = UIColor.white
        editName.layer.cornerRadius = cornerRadius
        editName.backgroundColor = UIColor.stellaPurple()
         str = NSMutableAttributedString(string: "Cancel", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 16.0)!])
        
        cancel.tintColor = UIColor.stellaPurple()
        //cancel.layer.cornerRadius = cornerRadius
        cancel.setAttributedTitle(str, for: .normal)
        cancel.backgroundColor = UIColor.white
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
