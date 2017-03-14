//
//  SearchUsernameTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/22/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
class SearchUsernameTableViewCell: UITableViewCell {
    @IBOutlet weak var profile:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var accessory:UIButton!
    var isAdded:Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        name.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        name.backgroundColor = UIColor.white
        profile.layer.cornerRadius = profile.frame.size.width/2.0
        profile.clipsToBounds = true
        accessory.backgroundColor = UIColor.stellaPurple()
        accessory.layer.cornerRadius = 2
        
        accessory.tintColor = UIColor.white
        print("check added value \(isAdded)")
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configureCell(user:User,img:UIImage? = nil) {
        if img != nil {
            self.profile.image = img!
        }
        else {
            if user.pictureURL != "" {
            let ref = FIRStorage.storage().reference(forURL:user.pictureURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("JESS: Unable to download image from Firebase storage")
                    self.profile.image = UIImage(named:"Trump")
                } else {
                    print("JESS: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profile.image = img
                         
                        }
                    }
                }
                
            })
            }
            else {
                self.profile.image = UIImage(named:"trump")
            }
        }
        
    }

}
