//
//  SettingTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/10/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import OneSignal
import BetterSegmentedControl
import Firebase
import DigitsKit
import ZAlertView

class SettingTableViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    let settings = [["Change Photo","Username","Email","Change Phone Number"],["Notification"],["Blocked","Log Out"]]
    let sections = ["Manage Account", "Notification","Actions"]
    
    var profileImage = UIImageView()
    var username = ""
    var previewClose = false
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViewDidLoad()
    }
    func prepareViewDidLoad() {
        if currentUser.profile != UIImage() {
            profileImage.image = currentUser.profile
        }
        else {
              profileImage.image = UIImage(named: "trump")
        }
        profileImage.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2.0
        profileImage.clipsToBounds = true
      
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.isOpaque = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),for:.default)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.stellaPurple()
        self.navigationItem.title = "Setting"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]


        profileImage.contentMode = .scaleAspectFill
        if let img = FriendListViewController.imageCache.object(forKey: NSString(string:currentUser.id)) {
            print("enter setting img cache")
               profileImage.image = img
        }
         else {
            if let list = UserDefaults.standard.object(forKey: currentUser.id) as? Data {
                self.profileImage.image = NSKeyedUnarchiver.unarchiveObject(with: list) as! UIImage
                self.tableView.reloadData()
            }
            
            queryForProfileImage()
        }
    }
    
    func queryForProfileImage() {
        if FIRAuth.auth()?.currentUser == nil {
            return
        }
        FIRDatabase.database().reference().child("Users/\(currentUser.id)").observe(.value, with: {snap in
            if snap.exists() {
                let dictionary = snap.value as! [String:AnyObject]
          let ref = FIRStorage.storage().reference(forURL:"gs://flagapp-11693.appspot.com/profileimages/\(currentUser.id).png")
                ref.data(withMaxSize: 1*1024*1024, completion: {(data,error) in
                    if error != nil && UserDefaults.standard.object(forKey: currentUser.id) == nil{
                        print("JESS: Unable to download image from Firebase storage")
                        self.profileImage.image = UIImage(named:"trump")
                    } else {
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.profileImage.image = img
                                User().setProfileImageOffline(image: img,key:currentUser.id)
                                FriendListViewController.imageCache.setObject(img, forKey:currentUser.id as NSString)
                                self.tableView.reloadData()
                            }
                        
                    }
 
                    }
                })
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         return headerView(section: section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settings", for: indexPath)
        cell.textLabel?.attributedText = NSAttributedString(string: settings[indexPath.section][indexPath.row], attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 17.0)!])
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.accessoryView = profileImage
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            let label = UILabel()
            if currentUser.username == "" {
                label.text = "Not register"
            }
            else{
                label.text = currentUser.username
            }
            label.textColor = UIColor.gray
            label.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            label.sizeToFit()
            cell.accessoryView = label
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            let label = UILabel()
            label.text = currentUser.email
            label.textColor = UIColor.gray
            label.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            label.sizeToFit()
             cell.accessoryView = label
        }
        if indexPath.section == 0 && (indexPath.row == 3 || indexPath.row == 4) || indexPath.section == 2 && indexPath.row == 0 {
            cell.accessoryType = .disclosureIndicator
        }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                if #available(iOS 10.0, *) {
                    let center = UNUserNotificationCenter.current()
                    center.getNotificationSettings { (settings) in
                        if(settings.authorizationStatus == .authorized)
                        {
                            cell.textLabel?.attributedText = NSAttributedString(string: "Disable Notification", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 17.0)!])
                        }
                        else
                        {
                            cell.textLabel?.attributedText = NSAttributedString(string: "Enable Notification", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 17.0)!])
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
                break
            default:
                break
            }
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                changeProfileImage()
                break
            case 1:
                if currentUser.username == "" {
                    let dialog = ZAlertView(title: "Add username", message: "Choose your username", closeButtonText: "OK", closeButtonHandler: {(ok) in
                        let username = ok.getTextFieldWithIdentifier("username")
                        FIRDatabase.database().reference().child("Users").queryOrdered(byChild: "username").queryEqual(toValue: username!.text!).observeSingleEvent(of: .value, with: {(snap) in
                            if snap.value is NSNull {
                                FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["username" : username!.text!])
                                ok.dismissAlertView()
                                ZAlertView(title: "Ok", message: "Your username is \(username!.text!)", closeButtonText: "Ok", closeButtonHandler: {(ok) in
                                    currentUser.username = username!.text!
                                    self.tableView.reloadData()
                                    ok.dismissAlertView()
                                }).show()
                            }else {
                                ZAlertView(title: "Already taken", message: "This username is already taken", closeButtonText: "Try Again", closeButtonHandler: {(ok) in
                                    ok.dismissAlertView()
                                }).show()
                            }
                        })
                })
                    dialog.addTextField("username", placeHolder: "Username")
                    dialog.show()
                }
               /* let view = self.storyboard?.instantiateViewController(withIdentifier: "changeusername") as! ChangeUsernameTableViewController
                self.tabBarController?.tabBar.isHidden = true
                self.navigationController?.pushViewController(view, animated: true) */
                break
            case 2:
                let view = self.storyboard?.instantiateViewController(withIdentifier: "changepassword") as! ChangePasswordTableViewController
                self.tabBarController?.tabBar.isHidden = true
                let nav = UINavigationController(rootViewController: view)
                self.navigationController?.present(nav, animated: true)
                break
            case 3:
                let view = self.storyboard?.instantiateViewController(withIdentifier: "digit") as! DigitTestViewController
                view.isChange = true
                self.tabBarController?.tabBar.isHidden = true
                 let nav = UINavigationController(rootViewController: view)
                self.navigationController?.present(nav, animated: true)
                break
            default:
                break
                
            }
        }
        else if indexPath.section == 1 {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.getNotificationSettings { (settings) in
                     UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                }
            } else {
                // Fallback on earlier versions
            }

        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "blocklist") as! BlockListViewController
                self.tabBarController?.tabBar.isHidden = true
                self.navigationController?.pushViewController(view, animated: true)
            }
            else {
               signOut()
            }
                
        }
    }
    func addUsername() {
        
    }
    func changeProfileImage() {
        let ac = UIAlertController(title: "Change Profile Photo", message: "", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take Photo", style:.default, handler:alertAction))
        ac.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: alertAction))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(ac,animated: true)
        
    }
    func notificationOn(sender:UISwitch){
        print("lolol")
        //UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
    }
    
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
            Digits.sharedInstance().logOut()
            let view = self.storyboard?.instantiateViewController(withIdentifier: "login")
           let nav = UINavigationController(rootViewController: view!)
            isLoad = true
           // self.present(nav, animated: true, completion: nil)
            self.performSegue(withIdentifier: "backtologin", sender: self)
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
        }
        catch {
            print("sign out error")
            let ac = UIAlertController(title: "Error", message: "Cannot sign out, Please try again.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                
                ac.dismiss(animated: true, completion: nil)
            }))
            self.present(ac, animated: true, completion: nil)
        }

    }
    func headerView(section:Int) -> UIView {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        returnedView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x:10, y: 5, width: view.frame.size.width, height: 20))
        label.textColor = UIColor.stellaPurple()
        label.attributedText = NSAttributedString(string: sections[section], attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 17.0)!])
        returnedView.addSubview(label)
        
        return returnedView
    }
    func alertAction(action: UIAlertAction!) {
        if action.title == "Take Photo" {
            takePhoto()
        }
        else {
            openPhoto()
        }
    }
    func openPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = (info["UIImagePickerControllerEditedImage"] as! UIImage)
        let data  = image.jpegData(.lowest)
        let png = UIImagePNGRepresentation((UIImage(data: data!)!))
        let ac = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ac.backgroundColor = UIColor.darkGray
        ac.layer.cornerRadius = 5.0
        ac.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        
        ac.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        ac.startAnimating()
        picker.view.addSubview(ac)
        picker.view.bringSubview(toFront: ac)
        uploadData(image: UIImage(data: png!)!)
    
    }
    func uploadData(image:UIImage) {

        
        let storage = FIRStorage.storage().reference().child("profileimages/\(currentUser.id).png")
        if let data = UIImagePNGRepresentation(image) {
            storage.put(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    let ac = UIAlertController(title: "Error", message: "Cannot set profile picture, Please try again.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                        ac.dismiss(animated: true, completion: nil)
                    }))
                    self.present(ac, animated: true, completion: nil)
                    return
                }
                self.profileImage.image = image
                self.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
                let downloadURL = metadata.downloadURL()
                print("downloadURl \(downloadURL)")
                 FIRDatabase.database().reference().child("Users/\(currentUser.id)/pictureURL").setValue("\(downloadURL!)")
            }
        }
        if let dat = UIImagePNGRepresentation(image.scaleImage(toSize: CGSize(width: 40, height: 40))!) {
            let st = FIRStorage.storage().reference().child("profilethumbnails/\(currentUser.id).png")
            st.put(dat, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    let ac = UIAlertController(title: "Error", message: "Cannot set profile picture, Please try again.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                        ac.dismiss(animated: true, completion: nil)
                    }))
                    self.present(ac, animated: true, completion: nil)
                    return
                }
                let downloadURL = metadata.downloadURL()
                print("downloadURl \(downloadURL)")
                FIRDatabase.database().reference().child("Users/\(currentUser.id)/thumbnailURL").setValue("\(downloadURL!)")
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
}
