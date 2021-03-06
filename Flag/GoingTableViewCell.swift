//
//  GoingTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/20/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
class GoingTableViewCell: UITableViewCell {
    @IBOutlet weak var profile:UIImageView!
    @IBOutlet weak var name:UILabel!
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
    func configureCell(user: User, img:UIImage? = nil) {
        self.name.text = user.username
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
                                // FriendListViewController.imageCache.setObject(img, forKey: user.id as NSString)
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


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
