//
//  BlockListTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/10/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
class BlockListTableViewCell: UITableViewCell {

    @IBOutlet weak var profile:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var accessory:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        name.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        name.backgroundColor = UIColor.white
        profile.layer.cornerRadius = profile.frame.size.width/2.0
        profile.clipsToBounds = true
        accessory.backgroundColor = UIColor.stellaPurple()
        accessory.layer.cornerRadius = 2
        
        accessory.tintColor = UIColor.white
        
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
                if let list = UserDefaults.standard.object(forKey: user.id) as? Data {
                    self.profile.image = NSKeyedUnarchiver.unarchiveObject(with: list) as! UIImage
                    
                    print("is it enter this if shit? \(self.profile.image)")
                }
                if let list = UserDefaults.standard.object(forKey: user.id) as? Data {}
                else {
                    self.profile.image = UIImage(named:"trump")
                }

            let ref = FIRStorage.storage().reference(withPath: "profilethumbnails/\(user.id).png")
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil && UserDefaults.standard.object(forKey: currentUser.id) == nil{
                    print("JESS: Unable to download image from Firebase storage")
                    self.profile.image = UIImage(named:"trump")
                } else {
                    print("JESS: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profile.image = img
                            User().setProfileImageOffline(image: img,key:user.id)
                            FriendListViewController.imageCache.setObject(img, forKey:user.id  as NSString)
                        }
                    }
                }
            })
        }
        
    }

}
