//
//  TitleTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/29/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {
    @IBOutlet weak var textField:UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        textField.placeholder = "Title"
        textField.textColor = UIColor.black
        textField.placeholder = "Title"
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
