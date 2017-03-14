//
//  NotificationTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/9/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var profile:UIImageView!
    @IBOutlet weak var notiDetail:UILabel!
    @IBOutlet weak var time:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.layer.cornerRadius = profile.frame.size.width/2.0
        profile.clipsToBounds = true
        // Initialization code
        notiDetail.numberOfLines = 0
        notiDetail.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(uid: String, img:UIImage? = nil) {
        // self.name.text = user.username
        if img != nil {
            self.profile.image = img!
        }
        if let list = UserDefaults.standard.object(forKey: uid) as? Data {
            self.profile.image = NSKeyedUnarchiver.unarchiveObject(with: list) as! UIImage
        }else{
            let ref = FIRStorage.storage().reference(withPath: "profilethumbnails/\(uid).png")
            ref.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error != nil && UserDefaults.standard.object(forKey: currentUser.id) == nil{
                    print("JESS: Unable to download image from Firebase storage")
                    self.profile.image = UIImage(named:"trump")
                } else {
                    print("JESS: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profile.image = img
                            User().setProfileImageOffline(image: img,key:uid)
                            FriendListViewController.imageCache.setObject(img, forKey: NSString(string: uid))
                        }
                    }
                }
            })
        }
    }
}
