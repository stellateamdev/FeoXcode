//
//  SetUserNameViewController.swift
//  LopeTalk
//
//  Created by marky RE on 11/9/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import OneSignal
import Fabric
import DigitsKit
import ZAlertView
class SetUserNameViewController: UIViewController {
    @IBOutlet weak var username:UITextField!
    @IBOutlet weak var set:UIButton!
    @IBOutlet weak var profilePicture:UIImageView!
    @IBOutlet weak var camera:UIImageView!
    let imageView = UIImageView();
    var check = false
    var activityActive = false
    var image:UIImage?
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Set Username"
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.delegate = self
        prepareView()
    }
       @IBAction func add(sender:UIButton){
        checkDuplicate()
       /* if !check {
         checkDuplicate()
        }
        else {
            print("KUYKUY")
            setUsername()
        } */
    }

    func checkDuplicate() {
        if self.username.text == "" {
            let dialog = ZAlertView(title: "Error",
                                    message: "Please enter username",
                                    closeButtonText: "Okay",
                                    closeButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
            return
        }
        self.username.endEditing(true)
        var duplicate = false
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        activityActive = true
        activity.startAnimating()
        FIRDatabase.database().reference().child("Users").queryOrdered(byChild: "username").queryEqual(toValue: self.username.text!.lowercased()).observeSingleEvent(of: .value, with: {(snap) in
            if snap.value is NSNull {
                print("nulllllll snap")
                activity.stopAnimating()
                self.activityActive = false
                self.set.setAttributedTitle(NSAttributedString(string: "Set", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]), for: .normal)
                self.check = true
                self.username.isEnabled = false
            }
            else {
                print("duplicate")
                duplicate = true
                }
                if !duplicate {
                   print("but it pass wtf")
                    self.activityActive = false
                    
                    let image = UIImage(named: "Checkmark");
                    self.imageView.image = image;
                    print("check user maxxyxyxy \(self.username.frame.maxX) \(self.username.frame.minY)")
                    self.imageView.frame = CGRect(x: self.username.frame.maxX-70, y: 0, width: 30, height: 30)
                    self.username.addSubview(self.imageView)
                    self.set.setAttributedTitle(NSAttributedString(string: "Set", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]), for: .normal)
                     activity.stopAnimating()
                    self.check = true
                    self.username.isEnabled = false
                    self.setUsername()
                    
                }
                else {
                     print("sould fuck up")
                    self.activityActive = false
                    activity.stopAnimating()
                    self.check = true
                    let image = UIImage(named: "DeleteRed");
                    self.imageView.image = image;
                    self.imageView.frame = CGRect(x: self.username.frame.maxX-70, y: 0, width: 30, height: 30)
                    self.username.addSubview(self.imageView)
                        let dialog = ZAlertView(title: "Error",
                                                message: "Username already taken",
                                                closeButtonText: "Okay",
                                                closeButtonHandler: { alertView in
                                                    alertView.dismissAlertView()
                                                   // imageView.removeFromSuperview()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                     self.check = false
                    
                }
            })
    }


    func setUsername() {
 
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        activityActive = true
        activity.startAnimating()
       print("before query")
        if self.profilePicture.image != nil {
            let storage = FIRStorage.storage().reference().child("profileimages/\(currentUser.id).png")
            if let data = UIImagePNGRepresentation(image!) {
            storage.put(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("upload error")
                    return
                }
                let downloadURL = metadata.downloadURL
                currentUser.username = self.username.text!.lowercased()
                currentUser.pictureURL = "\(downloadURL)"
                FIRDatabase.database().reference().child("Users/\(currentUser.id)").setValue(["uid":currentUser.id,"username":currentUser.username,"phonenumber":"","pictureURL":currentUser.pictureURL])
                activity.stopAnimating()
                print("GOGOGOGOGO")
               /*let view = self.storyboard?.instantiateViewController(withIdentifier: "digit") as! DigitTestViewController
               self.navigationController?.present(view, animated: true)*/
                self.performSegue(withIdentifier: "toDigit", sender: self)
                }
            }
            let dat = UIImagePNGRepresentation((self.profilePicture.image?.scaleImage(toSize: CGSize(width: 40, height: 40)))!)
                let st = FIRStorage.storage().reference().child("profilethumbnails/\(currentUser.id).png")
                st.put(dat!, metadata: nil) { (metadata, error) in
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
        else {
              currentUser.username = username.text!.lowercased()
            print("\(username.text!.lowercased()) \(currentUser.username)")
            activity.stopAnimating()
            print("GOGOGOGOGO")
            FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["username" : currentUser.username])
            /*let view = self.storyboard?.instantiateViewController(withIdentifier: "digit") as! DigitTestViewController
            print("check navigagion bar \(self.navigationController)")
            self.navigationController?.present(view, animated: true)*/
            self.performSegue(withIdentifier: "toDigit", sender: self)
        }
       /* OneSignal.idsAvailable({ (userId, pushToken) in
            print("onesignal")
            if (pushToken != nil) {
                print("finish sign up")
                let arr = ["Username":self.username.text!,"oneid":userId!,"id":"\(FIRAuth.auth()!.currentUser!.uid)","email":FIRAuth.auth()!.currentUser!.email]
                let savedData = NSKeyedArchiver.archivedData(withRootObject:arr)
                FIRDatabase.database().reference().child("Users/\(FIRAuth.auth()!.currentUser!.uid)").setValue(arr)
                UserDefaults.standard.set(savedData, forKey: "currentUser")
                UserDefaults.standard.synchronize()
                
            }
            else {
                print("the end")
                let arr = ["Username":self.username.text!,"oneid":"","id":"\(FIRAuth.auth()!.currentUser!.uid)","email":FIRAuth.auth()!.currentUser!.email]
                let savedData = NSKeyedArchiver.archivedData(withRootObject:arr)
                FIRDatabase.database().reference().child("Users/\(FIRAuth.auth()!.currentUser!.uid)").setValue(arr)
                UserDefaults.standard.set(savedData, forKey: "currentUser")
                UserDefaults.standard.synchronize()
            }
        }) */


    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension SetUserNameViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            self.set.setAttributedTitle(NSAttributedString(string: "Set", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]), for: .normal)
            self.check = false
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.imageView.removeFromSuperview()
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.set.setAttributedTitle(NSAttributedString(string: "Set", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]), for: .normal)
        self.check = false
        return true
    }
}
extension SetUserNameViewController {
    func prepareView() {
        self.view.endEditing(false)
        self.set.tintColor = UIColor.white
        self.set.layer.cornerRadius = 4
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.set.setAttributedTitle(NSAttributedString(string: "Set", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]), for: .normal)
        self.set.backgroundColor = UIColor.stellaPurple()
        self.username.addUnderline()
        self.profilePicture.isUserInteractionEnabled = true
        self.profilePicture.backgroundColor = UIColor.stellaPurple()
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height/2.0
        self.profilePicture.layer.shadowColor = UIColor.black.cgColor
        self.profilePicture.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.profilePicture.layer.shadowOpacity = 0.5
        self.profilePicture.layer.shadowRadius = 5
        self.profilePicture.layer.masksToBounds = false
        self.profilePicture.clipsToBounds = false
        
        
        self.profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SetUserNameViewController.setProfilePicture)))
        
    }
    func setProfilePicture() {
        let ac = UIAlertController(title: "Change Profile Photo", message: "", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take Photo", style:.default, handler:alertAction))
        ac.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: alertAction))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            print("enter ipad")
            ac.popoverPresentationController?.sourceView = self.view
            ac.popoverPresentationController?.sourceRect = CGRect(x: self.profilePicture.frame.maxX-60, y:self.profilePicture.frame.maxY, width: 0, height: 0)
            self.present(ac,animated: true)
        }
        else {
        self.present(ac,animated: true)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !activityActive {
            self.view.endEditing(true)
        }
    }

}

extension SetUserNameViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func alertAction(action: UIAlertAction!) {
        if action.title == "Take Photo" {
            takePhoto()
        }
        else {
            openPhoto()
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.camera.isHidden = true
        self.profilePicture.clipsToBounds = true
        self.profilePicture.image = (info["UIImagePickerControllerEditedImage"] as! UIImage)
        image = self.profilePicture.image
        self.dismiss(animated: true, completion: nil)
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
    

}
