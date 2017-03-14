//
//  ViewActivityTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/18/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class JoinViewTableViewCell: UITableViewCell {
    @IBOutlet weak var join:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        join.setTitle("Join", for: .normal)
        join.layer.cornerRadius = 5.0
        join.setAttributedTitle(NSAttributedString(string: "Join", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!]), for: .normal)
        join.backgroundColor = UIColor.lightGray
        join.tintColor = UIColor.white
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
