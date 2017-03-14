//
//  ActivityFeedTableViewCell.swift
//  Flag
//
//  Created by marky RE on 12/6/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
class ActivityFeedTableViewCell: UITableViewCell {
    @IBOutlet weak var profile:UIImageView!
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var sub:UILabel!
    @IBOutlet weak var location:UILabel!
    @IBOutlet weak var detail:UILabel!
    var num = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.layer.cornerRadius = profile.frame.size.width/2.0
        profile.clipsToBounds = true
        sub.textColor = UIColor.gray
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 17.0)
        label.textColor = UIColor.black
        sub.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        location.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        detail.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        location.textColor = UIColor.gray
        label.backgroundColor = UIColor.white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        location.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        detail.numberOfLines = 0
        detail.lineBreakMode = .byWordWrapping
        sub.backgroundColor = UIColor.white
        location.backgroundColor = UIColor.white
        // Initialization code
    }
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    func queryLocation(loc:CLLocationCoordinate2D) {
         let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            var str = ""
            // Address dictionary
            // print(placeMark.addressDictionary ?? "")
            
            // Location name
            if placeMark == nil {
                self.location.text = "Unknown Location"
                return
            }
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                str = "\(locationName)"
            }
            
            // Street address
            else if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                str = " \(street)"
            }
            
            // City
           else if let city = placeMark.addressDictionary!["City"] as? NSString {
                str = " \(city)"
            }
            
            // Zip code
            // Country
           else if let country = placeMark.addressDictionary!["Country"] as? NSString {
                str = " \(country)"
            }
            self.location.text = str
           // self.location.attributedText = self.addAttributedText(text: str)
    })
    
    }
    func configureCell(activity:ActivityData, img:UIImage? = nil) {
        if img != nil {
            self.profile.image = img!
            return
        }
        if let list = UserDefaults.standard.object(forKey: activity.id) as? Data {
            self.profile.image = NSKeyedUnarchiver.unarchiveObject(with: list) as! UIImage
            //userArray[self.num].profile = self.profile.image!
            print("is it enter this if shit? \(self.profile.image)")
        }else{
            let ref = FIRStorage.storage().reference(withPath: "profilethumbnails/\(activity.id).png")
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil && UserDefaults.standard.object(forKey: currentUser.id) == nil{
                    print("JESS: Unable to download image from Firebase storage")
                    self.profile.image = UIImage(named:"trump")
                } else {
                    print("JESS: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profile.image = img
                            User().setProfileImageOffline(image: img,key:activity.id)
                            //userArray[self.num].profile = img
                            ActivityFeedTableViewController.activityImageCache.setObject(img, forKey: activity.creator as NSString)
                        }
                    }
                }
            })
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func addAttributedText(text:String) -> NSAttributedString {
        let thetext = NSMutableAttributedString()
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "markergrey")
        attachment.bounds = CGRect(x: 0, y: -2, width: 15, height: 15)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string:text)
        thetext.append(attachmentString)
        thetext.append(attributedString)
        return thetext
    }

}
