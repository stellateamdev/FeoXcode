//
//  FriendListTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/3/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
class FriendListTableViewCell: UITableViewCell {
    @IBOutlet weak var profile:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var accessory:UIImageView!
    var num:Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        name.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        name.backgroundColor = UIColor.mapBackground()
        profile.layer.cornerRadius = profile.frame.size.width/2.0
        profile.clipsToBounds = true
        accessory.image = UIImage.init(named: "CircledUser")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        accessory.tintColor = UIColor.stellaPurple()
        accessory.backgroundColor = UIColor.mapBackground()
        accessory.isUserInteractionEnabled = true
   self.backgroundColor = UIColor.mapBackground()
        // Initialization code
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(user: User, img:UIImage? = nil) {
       // self.name.text = user.username
        if img != nil {
            self.profile.image = img!
        }
        else {
            if user.thumbnailURL != "" {
                if let list = UserDefaults.standard.object(forKey: user.id) as? Data {
                    self.profile.image = NSKeyedUnarchiver.unarchiveObject(with: list) as! UIImage
                    print("is it enter this if shit? \(self.profile.image)")
                }
                    let ref = FIRStorage.storage().reference(withPath: "profilethumbnails/\(user.id).png")
                    ref.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                        if error != nil && UserDefaults.standard.object(forKey: currentUser.id) == nil{
                            print("JESS: Unable to download image from Firebase storage")
                        } else {
                            print("JESS: Image downloaded from Firebase storage")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                self.profile.image = img
                                User().setProfileImageOffline(image: img,key:userArray[self.num].id)
                                print("userarray self.num \(userArray[self.num])")
                                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "updateProfile"), object: nil, userInfo:["data":userArray[self.num]])
                                FriendListViewController.imageCache.setObject(img, forKey: NSString(string: user.id))
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
