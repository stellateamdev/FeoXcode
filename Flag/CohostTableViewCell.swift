//
//  CohostTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/14/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
class CohostTableViewCell: UITableViewCell {
    @IBOutlet weak var profile:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var accessory:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        name.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        name.backgroundColor = UIColor.white
        profile.layer.cornerRadius = profile.frame.size.width/2.0
        profile.clipsToBounds = true
        //accessory.tintColor = UIColor.white
        //accessory.backgroundColor = UIColor.stellaPurple()
        
        // Initialization code
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
