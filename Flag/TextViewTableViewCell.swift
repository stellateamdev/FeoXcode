//
//  TextViewTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/13/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {
    @IBOutlet weak var textView:UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.sizeToFit()
        textView.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
