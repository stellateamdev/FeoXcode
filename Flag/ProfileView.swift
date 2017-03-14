//
//  ProfileView.swift
//  Flag
//
//  Created by marky RE on 12/2/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class ProfileView: UIView {
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var setname:UILabel!
    @IBOutlet weak var username:UILabel!
    @IBOutlet weak var close:UIButton!
    @IBOutlet weak var setting:UIButton!
    @IBOutlet weak var location:UIButton!
    
    var image = UIImage.init()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        self.close.tintColor = UIColor.lightGray
        self.close.setTitle("", for: .normal)
        
        self.setting.tintColor = UIColor.lightGray
        self.setting.setTitle("", for: .normal)
        self.setname.textAlignment = .center
        imageView.layer.cornerRadius = imageView.frame.size.width/2.0
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "DefineLocationFilled")?.withRenderingMode(.alwaysTemplate)
        attachment.bounds = CGRect(x:0,y:-7.0, width:attachment.image!.size.width-5, height:attachment.image!.size.height-5)
        let attachmentString = NSAttributedString(attachment: attachment)
        let str2 = NSMutableAttributedString(string: " Check location", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 17.0)!])
        let str = NSMutableAttributedString(string: " ")
        
        str.append(attachmentString)
        str.append(str2)
        
        location.setAttributedTitle(str, for: .normal)
        location.backgroundColor = UIColor.stellaPurple()
        location.tintColor = UIColor.white
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
