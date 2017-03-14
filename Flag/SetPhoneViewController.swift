//
//  SetPhoneViewController.swift
//  Flag
//
//  Created by marky RE on 11/30/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import PhoneNumberKit
import Firebase
import ZAlertView
class SetPhoneViewController: UIViewController {
    @IBOutlet weak var phonenumber:PhoneNumberTextField!
    @IBOutlet weak var chooseCountryCode:UIButton!
    @IBOutlet weak var setPhoneNumber:UIButton!
    @IBOutlet weak var setlater:UIButton!
    let phoneNumberKit = PhoneNumberKit()
    var region = ""
    var activityActive = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.tabBarController != nil {
            print("tabbar hide")
            if (self.tabBarController?.tabBar.isHidden)! {
                print("cehck 2 ifx")
                self.setlater.isHidden = true
            }
        }
        region = PhoneNumberKit.defaultRegionCode()
        chooseCountryCode.tintColor = UIColor.white
        chooseCountryCode.backgroundColor = UIColor.stellaPurple()
        chooseCountryCode.layer.cornerRadius = 3.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(SetPhoneViewController.changePhoneExtension), name: NSNotification.Name(rawValue: "changePhoneExtension"), object: nil)
        
        chooseCountryCode.setTitle("\(PhoneNumberKit.defaultRegionCode()) +\(Countries.phoneExtensionFromCountryCode(countryCode: region))", for: .normal)
        chooseCountryCode.addTarget(self, action: #selector(SetPhoneViewController.chooseCode), for: .touchUpInside)
        setPhoneNumber.tintColor = UIColor.white
        setPhoneNumber.backgroundColor = UIColor.stellaPurple()
        setPhoneNumber.layer.cornerRadius = 4
        setPhoneNumber.setAttributedTitle(NSAttributedString(string: "Continue", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!]), for: .normal)
        self.phonenumber.addUnderline()
       
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.setlater.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func setPhoneNum() {
         let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected")
            } else {
                let dialog = ZAlertView(title: "Error",
                                        message: "No internet connection, Please try again later.",
                                        closeButtonText: "Okay",
                                        closeButtonHandler: { alertView in
                                            alertView.dismissAlertView()
                }
                )
                dialog.allowTouchOutsideToDismiss = false
                /* let attrStr = NSMutableAttributedString(string: "Are you sure you want to quit?")
                 attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSMakeRange(10, 12))
                 dialog.messageAttributedString = attrStr */
                dialog.show()
                return
                
                
            }
        })

        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        activityActive = true
        activity.startAnimating()
        do {
            let parsephoneNumber = try phoneNumberKit.parse(phonenumber.text!, withRegion: region, ignoreType: true)
            syncPhone(phone: parsephoneNumber)
            /*let view = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
            self.navigationController?.present(view!, animated: true, completion: nil)*/
            self.performSegue(withIdentifier: "toTab", sender: self)
            
        } catch {
            do {
                let parsephoneNumber = try phoneNumberKit.parse(phonenumber.text!)
                syncPhone(phone: parsephoneNumber)
                /*let view = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
                self.navigationController?.present(view!, animated: true, completion: nil)*/
                self.performSegue(withIdentifier: "toTab", sender: self)
            } catch {
                activity.stopAnimating()
                activityActive = false
                let ac = UIAlertController(title: "Error", message: "Phone number is not in correct format, Please try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                    ac.dismiss(animated: true, completion: nil)
                    self.phonenumber.text = ""
                }))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
    func syncPhone(phone:PhoneNumber) {
    FIRDatabase.database().reference().child("Users/\(currentUser.id)/phoneNumber").setValue("\(phone.countryCode)\(phone.nationalNumber)")
    }
    @IBAction func setLater() {
        /*let view = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
         self.navigationController?.present(view!, animated: true, completion: nil)*/
        self.performSegue(withIdentifier: "toTab", sender: self)
    }
    
    func chooseCode() {
        self.performSegue(withIdentifier: "countrycode", sender: self)
    }
    func changePhoneExtension(_ noti:Notification) {
        let phoneExtension = noti.userInfo?["phoneextension"] as! String
        let countryCode = noti.userInfo?["region"] as! String
        chooseCountryCode.setTitle("\(countryCode) +\(phoneExtension)", for: .normal)
        region = countryCode
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
