//
//  AllActivityTableViewCell.swift
//  Flag
//
//  Created by marky RE on 3/18/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import Firebase
class AllActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var time:UILabel!
    @IBOutlet weak var title:UILabel!
    @IBOutlet  weak var join:UILabel!
    @IBOutlet weak var imgView:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareView()
        // Initialization code
        
    }
    func prepareView() {
        imgView.layer.cornerRadius = 22.5
        imgView.layer.masksToBounds = true
        title.numberOfLines = 0
        time.numberOfLines = 0
        join.numberOfLines = 0
    }
    func configureCell(activity:ActivityData, img:UIImage? = nil) {
        if img != nil {
            self.imgView.image = img!
            return
        }
        if let list = UserDefaults.standard.object(forKey: activity.id) as? Data {
            self.imgView.image = (NSKeyedUnarchiver.unarchiveObject(with: list) as! UIImage)
        }
        let ref = FIRStorage.storage().reference(withPath: "profilethumbnails/\(activity.id).png")
        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil && UserDefaults.standard.object(forKey: currentUser.id) == nil {
                print("JESS: Unable to download image from Firebase storage")
                self.imgView.image = UIImage(named:"trump")
            } else {
                print("JESS: Image downloaded from Firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.imgView.image = img
                        User().setProfileImageOffline(image: img,key:activity.id)
                        //userArray[self.num].profile = img
                        AllActivityTableViewController.activityImageCache.setObject(img, forKey: activity.creator as NSString)
                    }
                }
            }
        })
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
