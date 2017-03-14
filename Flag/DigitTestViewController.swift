//
//  DigitTestViewController.swift
//  Flag
//
//  Created by marky RE on 12/21/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import DigitsKit
import Firebase
class DigitTestViewController: UIViewController {
    @IBOutlet weak var setLater:UIButton!
    var isChange = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LOLOLOLOPL")
            if isChange {
                print("cehck 2 ifx")
                self.setLater.isHidden = true
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
                let leftButton = UIBarButtonItem(image: UIImage(named:"Delete"), style: .plain, target: self, action: #selector(ChangePasswordTableViewController.closeView))
                leftButton.tintColor = UIColor.stellaPurple()
                
                self.navigationItem.leftBarButtonItem = leftButton
                self.navigationItem.title = "Change Your Phone Number"
                self.navigationController?.navigationBar.titleTextAttributes =  [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]
            }
        let authButton = DGTAuthenticateButton(authenticationCompletion: {(session , error) in
            print("if error \(error) \(session)")
            if (session != nil) {
                print("hello mate session \(session!.phoneNumber)")
                // TODO: associate the session userID with your user model
                Digits.sharedInstance().logOut()
                let message = "Phone number: \(session!.phoneNumber)"
                let alertController = UIAlertController(title: "You've already registered your phone number, by pressing continue the previous phone number will be delete. Do you want to contiue?", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
                alertController.addAction(UIAlertAction(title: "Continue", style: .destructive , handler: {_ in
                    
                    currentUser.phoneNumber = session!.phoneNumber
                    FIRDatabase.database().reference().child("Users/\(currentUser.id)").updateChildValues(["uid":currentUser.id,"email":currentUser.email,"username":currentUser.username,"oneid":currentUser.oneid,"phonenumber":session!.phoneNumber,"pictureURL":currentUser.pictureURL])
                    if self.isChange {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        self.performSegue(withIdentifier: "toTab", sender: self)
                        /*let view = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
                        self.navigationController?.present(view!, animated: true, completion: nil)*/
                    }
                }))
                self.present(alertController, animated: true, completion: .none)

                
            } else {
                let alertController = UIAlertController(title: "Error", message:"Add phone number error, please try again", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: .none))
                        self.present(alertController, animated: true, completion: .none)
                NSLog("Authentication error: %@", error!.localizedDescription)
            }
        })
        authButton?.setTitle("Set my phone number", for: .normal)
        authButton?.digitsAppearance = makeTheme()
        authButton?.center = self.view.center
        self.view.addSubview(authButton!)
        // Do any additional setup after loading the view.
    }
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    func makeTheme() -> DGTAppearance {
        let theme = DGTAppearance();
        theme.bodyFont = UIFont(name: "HelveticaNeue-Light", size: 16);
        theme.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 17);
        theme.accentColor = UIColor.stellaPurple()//UIColor(red: (255.0/255.0), green: (172/255.0), blue: (238/255.0), alpha: 1);
        theme.backgroundColor = UIColor.white//UIColor(red: (240.0/255.0), green: (255/255.0), blue: (250/255.0), alpha: 1);
        // TODO: set a UIImage as a logo with theme.logoImage
        return theme;
    }

    @IBAction func setPhoneLater() {
        FIRDatabase.database().reference().child("Users/\(currentUser.id)").setValue(["uid":currentUser.id,"email":currentUser.email,"username":currentUser.username,"oneid":currentUser.oneid,"phonenumber":"","pictureURL":currentUser.pictureURL])
            /*let view = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
            self.navigationController?.present(view!, animated: true, completion: nil)*/
        self.performSegue(withIdentifier: "toTab", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
