//
//  ViewController.swift
//  Flag
//
//  Created by marky RE on 11/24/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import OneSignal
import Firebase
import FBSDKLoginKit
import ZAlertView
class LoginController: UIViewController,FBSDKLoginButtonDelegate {
    @IBOutlet weak var loginButton:FBSDKLoginButton!
    @IBOutlet weak var username:UITextField!
    @IBOutlet weak var password:UITextField!
    @IBOutlet weak var signIn:UIButton!
    @IBOutlet weak var signUp:UIButton!
    @IBOutlet weak var forgotPassword:UIButton!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.isOpaque = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),for:.default)
        self.navigationController?.navigationBar.barTintColor = UIColor.stellaPurple()
        self.navigationController?.setNavigationBarHidden(true, animated:true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        loginButton.delegate = self
        self.view.backgroundColor = UIColor.stellaPurple()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.username.textColor = UIColor.black
        self.password.textColor = UIColor.black
        self.signUp.tintColor = UIColor.white
        if FIRAuth.auth()?.currentUser != nil {
            let view = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
            self.navigationController?.present(view!, animated: true, completion: nil)
        }

      //autosignIn()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            print("login error")
            return
        }
        else {
            if let token = FBSDKAccessToken.current() {
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                if error == nil {
                    OneSignal.idsAvailable({ (userId, pushToken) in
                        FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["oneid" : userId])
                        if (pushToken != nil) {
                            print("Sending Test Noification to this device now");
                            OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [userId]]);
                        }
                    });
                    FIRDatabase.database().reference().child("Users/\(user!.uid)").observeSingleEvent(of: .value, with: {
                        (snap) in
                        if snap.value is NSNull {
                        }
                        else {
                            let dict = snap.value as! [String:AnyObject]
                            print(dict)
                            let arr = ["Username":dict["Username"]! as! String,"oneid":dict["oneid"]! as! String,"id":dict["id"]! as! String,"email":(user?.email!)!] as [String : String]
                            let savedData = NSKeyedArchiver.archivedData(withRootObject:arr)
                            UserDefaults.standard.set(savedData, forKey: "currentUser")
                            UserDefaults.standard.synchronize()
//                            self.performSegue(withIdentifier: "showFriendList", sender: self)
                            
                        }
                        
                    })
                }
                else {
                    print(error?.localizedDescription ?? "error")
                    print("credential error")
                }
            }
        }
            else {
                print("no facebook token")
            }
        }
        // ...
    }
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    func autosignIn() {
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        activity.startAnimating()
            self.view.endEditing(true)
            FIRAuth.auth()?.signIn(withEmail:"Boss@mm.com" , password: "Boss1234") { (user, error) in
                if error == nil {
                    FIRDatabase.database().reference().child("Users/\(user!.uid)").observeSingleEvent(of: .value, with: {
                        (snap) in
                        if snap.value is NSNull {
                        }
                        else {
                            OneSignal.idsAvailable({ (userId, pushToken) in
                                FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["oneid" : userId])
                                if (pushToken != nil) {
                                    print("Sending Test Noification to this device now");
                                    OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [userId]]);
                                }
                            });
                            let dict = snap.value as! [String:AnyObject]
                            print(dict)
                            /*    let arr = ["username":dict["username"]! as! String,"oneid":dict["oneid"]! as! String,"id":dict["id"]! as! String,"email":self.username.text!] as [String : String]
                             let savedData = NSKeyedArchiver.archivedData(withRootObject:arr)
                             UserDefaults.standard.set(savedData, forKey: "currentUser")
                             UserDefaults.standard.synchronize() */
                            activity.stopAnimating()
                            let view = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
                            self.navigationController?.present(view!, animated: true, completion: nil)
                            
                        }
                        
                    })
                    
                }
                else {
                     activity.stopAnimating()
                    let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
                    connectedRef.observe(.value, with: { snapshot in
                        if let connected = snapshot.value as? Bool, connected {
                            print("Connected")
                            let dialog = ZAlertView(title: "Error",
                                                    message: "E-mail or Password is Incorrect, Please try again.",
                                                    closeButtonText: "Okay",
                                                    closeButtonHandler: { alertView in
                                                        alertView.dismissAlertView()
                            }
                            )
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()

                        } else {
                            
                            let dialog = ZAlertView(title: "Error",
                                                    message: "Connection Error, Please try again.",
                                                    closeButtonText: "Okay",
                                                    closeButtonHandler: { alertView in
                                                        alertView.dismissAlertView()
                            }
                            )
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        }
                    })
                }
            }
        } 

    
    @IBAction func SignIn(_ sender: Any) {
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        activity.startAnimating()
        if username.text == "" || password.text == "" {
            activity.stopAnimating()
            
            let dialog = ZAlertView(title: "Error",
                                    message: "Please fill in both fields",
                                    closeButtonText: "Okay",
                                    closeButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
        else {
            self.view.endEditing(true)
            FIRAuth.auth()?.signIn(withEmail:self.username.text! , password: self.password.text!) { (user, error) in
                if error == nil {
                    FIRDatabase.database().reference().child("Users/\(user!.uid)").observeSingleEvent(of: .value, with: {
                        (snap) in
                        if snap.value is NSNull {
                        }
                        else {
                            let dict = snap.value as! [String:AnyObject]
                            print(dict)
                        /*    let arr = ["username":dict["username"]! as! String,"oneid":dict["oneid"]! as! String,"id":dict["id"]! as! String,"email":self.username.text!] as [String : String]
                            let savedData = NSKeyedArchiver.archivedData(withRootObject:arr)
                            UserDefaults.standard.set(savedData, forKey: "currentUser")
                            UserDefaults.standard.synchronize() */
                            activity.stopAnimating()
                            currentUser.email = FIRAuth.auth()!.currentUser!.email!
                            currentUser.id = FIRAuth.auth()!.currentUser!.uid
                        let view = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
                           // self.present(view!, animated: true, completion: nil)
                            self.performSegue(withIdentifier: "showFriendList", sender: self)
                            
                        }
                        
                    })
                    
                }
                else {
                    activity.stopAnimating()
                    let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
                    connectedRef.observe(.value, with: { snapshot in
                        if let connected = snapshot.value as? Bool, connected {
                            print("Connected")
                            let dialog = ZAlertView(title: "Error",
                                                    message: "E-mail or Password is Incorrect, Please try again.",
                                                    closeButtonText: "Okay",
                                                    closeButtonHandler: { alertView in
                                                        alertView.dismissAlertView()
                            }
                            )
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                            
                        } else {
                            
                            let dialog = ZAlertView(title: "Error",
                                                    message: "Connection Error, Please try again.",
                                                    closeButtonText: "Okay",
                                                    closeButtonHandler: { alertView in
                                                        alertView.dismissAlertView()
                            }
                            )
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        }
                    })
                }
            }
        } 
        


    }
    @IBAction func gotoSignup() {
        print("kiop[ \(self.navigationController)")
        let view = self.storyboard?.instantiateViewController(withIdentifier: "signup")
        self.navigationController?.pushViewController(view!, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

