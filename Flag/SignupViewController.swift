//
//  SignupViewController.swift
//  Flag
//
//  Created by marky RE on 11/24/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import OneSignal
import FBSDKLoginKit
import Firebase
import ZAlertView
class SignupViewController: UIViewController,FBSDKLoginButtonDelegate {
    @IBOutlet weak var loginButton:FBSDKLoginButton!
    @IBOutlet weak var username:UITextField!
    @IBOutlet weak var password:UITextField!
    @IBOutlet weak var signUp:UIButton!
    @IBOutlet weak var textLabel:UILabel!
    
    var activityActive = false
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Sign up"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),for:.default)
        self.view.backgroundColor = UIColor.stellaPurple()
        textLabel.numberOfLines = 0
        self.textLabel.textColor = UIColor.white
        self.username.textColor = UIColor.black
        self.password.textColor = UIColor.black
        self.signUp.tintColor = UIColor.white
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.text = "Set your email\n and your password 😎"
        
        username.tag = 0
        username.returnKeyType = .next
        password.tag = 0
        password.returnKeyType = .done
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
         loginButton.delegate = self
        
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !activityActive {
            self.view.endEditing(true)
        }
        else {
            
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            password.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }

        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signUp(sender:UIButton) {
        self.view.endEditing(true)
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        activityActive = true
        activity.startAnimating()
        FIRAuth.auth()?.createUser(withEmail: self.username.text!, password: self.password.text!, completion: {(user, error) in
            if error == nil {
                print("pass query")
                activity.stopAnimating()
                self.activityActive = false
                OneSignal.idsAvailable({ (userId, pushToken) in
                    if (pushToken != nil) {
                        FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["oneid" : userId,"username" : "","pictureURL" : "","thumbnailURL" : ""])
                    }
                })
                currentUser.email = FIRAuth.auth()!.currentUser!.email!
                currentUser.id = FIRAuth.auth()!.currentUser!.uid
                let view = self.storyboard?.instantiateViewController(withIdentifier: "setUsername") as! SetUserNameViewController
                self.navigationController?.pushViewController(view, animated: true)
            }
            else {
                activity.stopAnimating()
                let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
                connectedRef.observe(.value, with: { snapshot in
                    if let connected = snapshot.value as? Bool{
                        print("print connected \(connected)")
                    if connected {
                        print("Connected")
                        let dialog = ZAlertView(title: "Error",
                                                message: "Sign up Error, E-mail has already been taken. Please try again.",
                                                closeButtonText: "Okay",
                                                closeButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                        else {
                            print("disconnected")
                            let dialog = ZAlertView(title: "Error",
                                                    message: "Connection Error, Please try again.",
                                                    closeButtonText: "Okay",
                                                    closeButtonHandler: { alertView in
                                                        alertView.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        }
                    
                    }
                })
            }
        })
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
                        let view = self.storyboard?.instantiateViewController(withIdentifier: "setUsername") as! SetUserNameViewController
                        self.navigationController?.pushViewController(view, animated: true)
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

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
