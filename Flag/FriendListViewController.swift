//
//  FriendListViewController.swift
//  Flag
//
//  Created by marky RE on 11/25/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import OneSignal
import  MapKit
import Firebase
import ZAlertView
class FriendListViewController: UIViewController {

    @IBOutlet weak var searchView:UIView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var add:UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView:UIView!
    @IBOutlet weak var topLabel:UILabel!
    
    var touchSearchView = false
    var searchActive = false
    var buttomHeight:CGFloat?
    var firstCell:IndexPath?
    var searchArray:[User] = []
    var profileView:ProfileView?
    var settingView:SettingView?
    var profileIndex:Int!
    var grayView:UIView = UIView()
    var defaultMaxY:CGFloat?
    static var imageCache = NSCache<NSString, UIImage>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareViewWillAppear()
        
        if isLoad {
        prepareBackgroundView()
            isLoad = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViewDidLoad()
        if FIRAuth.auth()?.currentUser != nil {
        FIRDatabase.database().reference().child("Users/\(currentUser.id)").observeSingleEvent(of: .value, with: {(snap) in
            if snap.value is NSNull {
                
            }else{
                let dict = snap.value as! NSDictionary
                print(dict)
                if dict["username"] == nil {
                    
                }else{
                    self.queryCurrentUser()
                    self.queryFriendList()
                }
            }
        })
        }
        defaultMaxY = (viewHeight! as CGFloat)-tabbarHeight!-(self.buttomHeight!)
    }
    
    func queryCurrentUser() {
        FIRDatabase.database().reference().child("Users/\(currentUser.id)").observeSingleEvent(of: .value, with: {snap in
            if snap.exists() {
                let dictionary = snap.value as! [String:AnyObject]
               currentUser.username = dictionary["username"] as! String
                currentUser.phoneNumber = dictionary["phonenumber"] as! String
                currentUser.pictureURL = dictionary["pictureURL"] as! String
                currentUser.email = FIRAuth.auth()!.currentUser!.email!
                //currentUser.thumbnailURL = dictionary["thumbnailURL"] as! String
                currentUser.id = FIRAuth.auth()!.currentUser!.uid
                currentUser.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(dictionary["Latitude"] as! String)!, longitude: CLLocationDegrees(dictionary["Longitude"] as! String)!)
                if currentUser.oneid == "" {
                    OneSignal.idsAvailable({ (userId, pushToken) in
                        if (pushToken != nil) {
                            //FIRDatabase.database().reference().child("Users/\(FIRAuth.auth()!.currentUser!.uid)").updateChildValues(["oneid" : userId])
                        }
                    })
                }
                if currentUser.thumbnailURL != "" {
                        let ref = FIRStorage.storage().reference(forURL:currentUser.thumbnailURL)
                        ref.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                            if error != nil {
                                print("JESS: Unable to download image from Firebase storage")
                                //currentUser.profile = UIImage(named:"Trump")!
                            } else {
                                print("JESS: Image downloaded from Firebase storage")
                                if let imgData = data {
                                    if let img = UIImage(data: imgData) {
                                        currentUser.profile = img
                                     // NotificationCenter.default.post(name:NSNotification.Name(rawValue: "updateProfile"), object: nil, userInfo:["updateDisplay":currentUser.profile,"updateid":FIRAuth.auth()!.currentUser!.uid])
                                        FriendListViewController.imageCache.setObject(img, forKey: currentUser.id as NSString)
                                    }
                                }
                            }
                            
                        })
                    }
                 //self.postNotification(currentUser,notiname: "createFriendAnnotation")
            }
            else {
                print("current snap not exist")
            }
        })
    }
    
    func queryFriendList() {
        let scoresRef = FIRDatabase.database().reference(withPath: "Users/\(currentUser.id)/Friendlist")
        scoresRef.keepSynced(true)
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Friendlist").observe(.value, with: { snap in
            print("queryfriendlist")
            if !snap.exists() {
                print("queryfriendlist null")
            }
            else {
                let list = snap.value as! NSDictionary
                var index = 0
                    for uid in list {
                        for user in userArray{
                            if user.id == uid.value as! String {
                                continue
                            }
                        }
                        FIRDatabase.database().reference().child("Users/\(uid.value as! String)").observe(.value, with: {snap in
                            if snap.exists() {
                                let dict = snap.value as! NSDictionary
                                print(dict)
                                for user in userArray{
                                    if user.id == uid.value as! String {
                                        user.latitude = Double(dict["Latitude"] as! String)!
                                        user.longitude = Double(dict["Longitude"] as! String)!
                                        user.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(dict["Latitude"] as! String)!), longitude:  CLLocationDegrees(Double(dict["Longitude"] as! String)!))
                                        self.postNotification(user,notiname: "createFriendAnnotation")
                                        return
                                    }
                                }
                                if dict["Latitude"] != nil && dict["Longitude"] != nil {
                                    print(dict["thumbnailURL"])
                                    userArray.append(User(id:(dict["uid"] as! String),oneid: (dict["oneid"] as! String),username: (dict["username"] as! String), email: (dict["email"] as! String), latitude:(Double(dict["Latitude"] as! String)),longitude:(Double(dict["Longitude"] as! String)),pictureURL: (dict["pictureURL"] as! String),location:CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(dict["Latitude"] as! String)!), longitude:  CLLocationDegrees(Double(dict["Longitude"] as! String)!)),thumbnailURL: (dict["thumbnailURL"] as! String)))
                                    self.postNotification(userArray[index],notiname: "createFriendAnnotation")
                                }
                                else {
                                    userArray.append(User(id:(dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String), pictureURL: (dict["pictureURL"] as! String),thumbnailURL: (dict["thumbnailURL"] as! String)))
                                }
                                
                                self.postNotification(userArray[index],notiname: "createFriendAnnotation")
                                index+=1
                                self.tableView.reloadData()
                            }
                            else {
                                print("queryfriendlist snap.value is indeed null")
                            }
                        })
                }
  
            }
        })
    }

    func observeFriendAdded() {

    }
    
    func observeFriendRemoved() {

    }
    
    func observeFriendDataChanged() {
    
    }
 
    func blockUser(sender:UIButton) {
        print("sender.tag \(sender.tag) \(userArray[0].id)")
        let num = sender.tag
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Friendlist/\(userArray[num].id)").removeValue()
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Blocklist").updateChildValues(["\(userArray[num].id)":"\(userArray[num].id)"])
        self.postNotification(userArray[num], notiname: "removeFriendAnnotation")
         userArray.remove(at: num)
         self.tableView.reloadData()
        if (self.settingView?.isHidden)! {
            self.closeView(setting: false)
        }
        else {
            self.closeView(setting: true)
        }
    }
    
    
      override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor.mapBackground()
    }
    
    func postNotification(_ user:User, notiname:String) {
        print("check post noti \(user.latitude)")
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: notiname), object: nil, userInfo:["data":user])
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    func closeView(setting:Bool) {
        if (settingView?.isHidden)! {
        UIView.transition(with: self.profileView!, duration:0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.grayView.alpha = 0.0
            self.profileView?.alpha = 0.0
           
            
        }, completion: {_ in self.profileView?.imageView.image = nil})
        }
        else {
            if setting {
                UIView.transition(with: self.settingView!, duration:0.2, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
                    
                    self.settingView?.alpha = 0.0
                    self.profileView?.alpha = 0.0
                     self.grayView.alpha = 0.0
                    
                    
                }, completion: { _ in
                    self.settingView?.isHidden = true })
            }
            else {
            UIView.transition(with: self.settingView!, duration:0.2, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
                
                self.settingView?.alpha = 0.0
                
                
            }, completion: { _ in
            self.settingView?.isHidden = true })
        }
        }
       
        
    }
    func tapSetting() {
       
        //self.view.bringSubview(toFront: self.settingView!)
        UIView.transition(with: self.profileView!, duration:0.2, options: UIViewAnimationOptions.showHideTransitionViews, animations: {
            self.settingView?.isHidden = false
            self.settingView?.alpha = 1.0
            self.settingView?.name.text = self.profileView?.setname.text!
        }, completion: nil)
        
    }
    func showLocation(sender:UIButton) {
        
        let num = sender.tag
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.frame = CGRect(x:0,y:(self?.defaultMaxY!)!,width: (self?.view.frame.width)!, height:(self?.view.frame.height)!)
            
        }
        self.closeView(setting: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tapFriendLocation"), object: nil, userInfo: ["data":userArray[num]])
    }
    func showProfile(sender:UITapGestureRecognizer) {
        let tag = (sender.view as! UIImageView).tag
        self.profileView?.location.tag = tag
        UIView.transition(with: self.view, duration: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.settingView?.block.tag = tag
            self.grayView.alpha = 1.0
            self.profileView?.alpha = 1.0
            self.profileView?.setname.text = userArray[tag].username
            self.profileView?.username.text = userArray[tag].editName
            if userArray[tag].editName != "" {
                 self.settingView?.name.text = userArray[tag].editName
                self.settingView?.subname.text  = userArray[tag].username
            }
            else {
                self.settingView?.name.text = userArray[tag].username
                self.settingView?.subname.text  = ""
            }
           
            let cell = self.tableView.cellForRow(at: NSIndexPath(row: tag, section: 0) as IndexPath) as! FriendListTableViewCell
            self.profileView?.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FriendListViewController.showProfileImage)))
            self.profileIndex = tag
            if cell.profile.image != nil {
                let img = cell.profile.image
                self.profileView?.imageView.image = img!
            }else {
                self.profileView?.imageView.image = UIImage(named:"trump")
            }
        }, completion: nil)
    }
    
    
    func showProfileImage(num:Int) {
        let view  = self.storyboard?.instantiateViewController(withIdentifier: "showDisplay") as! ShowDisplayViewController
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        self.profileView?.alpha = 0.0
        self.grayView.alpha = 0.0
        activity.startAnimating()
        print("hello mate \(view.imageView)")
        if let img = FriendListViewController.imageCache.object(forKey: "\(userArray[self.profileIndex].id)big" as NSString) {
            view.image = img
            view.view.tag = 10
            view.view.frame = CGRect(x: 0, y:self.view.frame.maxY, width: self.view.frame.size.width, height: self.view.frame.size.height)
            activity.stopAnimating()
            self.addChildViewController(view)
            self.view.addSubview(view.view)
            self.profileView?.alpha = 0.0
            self.grayView.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: {_ in
                view.view.frame = CGRect(x: 0, y:-33.0, width: self.view.frame.size.width, height: self.view.frame.size.height+33.0)
            },completion: {_ in
                view.didMove(toParentViewController: self)
            })
            self.tabBarController?.tabBar.isHidden = true
        }else{
            print("check user pictureURL \(currentUser.pictureURL)\(num)")
            let ref = FIRStorage.storage().reference(withPath: "profileimages/\(userArray[self.profileIndex].id).png")
            ref.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    activity.stopAnimating()
                    print("JESS: Unable to download image from Firebase storage")
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

                } else {
                    print("JESS: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            view.image = img
                            FriendListViewController.imageCache.setObject(img, forKey: "\(currentUser.id)big" as NSString)
                            view.view.tag = 10
                            view.view.frame = CGRect(x: 0, y:self.view.frame.maxY, width: self.view.frame.size.width, height: self.view.frame.size.height)
                            activity.stopAnimating()
                            self.addChildViewController(view)
                            self.view.addSubview(view.view)
                            self.profileView?.alpha = 0.0
                            self.grayView.alpha = 0.0
                            UIView.animate(withDuration: 0.3, animations: {_ in
                                view.view.frame = CGRect(x: 0, y:-33.0, width: self.view.frame.size.width, height: self.view.frame.size.height+33.0)
                            },completion: {_ in
                                view.didMove(toParentViewController: self)
                            })
                            self.tabBarController?.tabBar.isHidden = true
                        }
                    }
                }
            })
        }
       // view.imageView.image = self.profileView!.imageView.image
    }
    func closeImageView() {
        for subview in self.view.subviews {
            if subview.tag == 10 {
                subview.removeFromSuperview()
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
            if searchView.frame.contains((touches.first?.location(in: self.view))!) {
                 touchSearchView = true
            }
        }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchSearchView = false
    }
    func tapTopView(){
        if self.view.frame.minY == viewHeight!-viewHeight!*3.8/4.0 {
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.view.frame = CGRect(x:0,y:(viewHeight! as CGFloat) - tabbarHeight! - (self?.buttomHeight!)!,width: (self?.view.frame.width)!, height:(self?.view.frame.height)!)
            })
        }
        else {
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
          self?.view.frame = CGRect(x:0,y:viewHeight!-viewHeight!*3.8/4.0,width: (self?.view.frame.width)!, height:(self?.view.frame.height)!)
        })
        }
    }

    func finishEditName(sender:UIButton) {
        let num = sender.tag
        let dialog = ZAlertView(title: "Edit Name", message: "Enter new name", isOkButtonLeft: false, okButtonText: "Set", cancelButtonText: "Cancel",
                                okButtonHandler: { alertView in
                                    userArray[num].editName = alertView.getTextFieldWithIdentifier("New name")!.text!
                                    self.profileView?.setname.text = userArray[num].editName
                                    self.profileView?.username.text = currentUser.username
                                    self.settingView?.name.text =  userArray[num].editName
                                    self.settingView?.subname.text = currentUser.username
                                    self.tableView.reloadData()
                                    alertView.dismissAlertView()
        },
                                cancelButtonHandler: { alertView in
                                    alertView.dismissAlertView()
        }
        )
        dialog.addTextField("New name", placeHolder: "New name")
        dialog.show()
        self.tableView.reloadData()
        print("ded")
    }
    
    
    
}



extension FriendListViewController {
    func prepareViewWillAppear() {
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.view.backgroundColor = UIColor.mapBackground()
        add.setImage(UIImage.init(named: "AddUser")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        add.imageView?.tintColor = UIColor.stellaPurple()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func addBlur() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }
    
    func prepareBackgroundView(){
        print("check nil \(viewHeight) \(tabbarHeight) \(buttomHeight)")
        view.frame = CGRect.init(x:0, y:((viewHeight! as CGFloat) - tabbarHeight! - buttomHeight!) ,width: self.view.frame.width,height: self.view.frame.height)
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.layer.shadowColor = UIColor.black.cgColor
            self.view.layer.shadowOpacity = 0.34
            self.view.layer.shadowOffset = CGSize.zero
            self.view.layer.shadowRadius = 6
        }
        self.view.backgroundColor = UIColor.mapBackground()
        self.view.layer.cornerRadius = 12.0
        
        self.tableView.backgroundColor = UIColor.mapBackground()
        self.searchView.backgroundColor = UIColor.mapBackground()
        
        self.topView.backgroundColor = UIColor.mapBackground()
        self.topView.layer.cornerRadius = 12.0
        self.topView.clipsToBounds = true
        
        UITabBar.appearance().tintColor = UIColor(red: 179/255.0, green: 179/255.0, blue: 179/255.0, alpha: 1.0)
        self.tabBarController?.tabBar.alpha = 0.87
        self.tabBarController?.tabBar.barTintColor = UIColor.mapBackground()
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.barStyle = .black
        self.tabBarController?.tabBar.selectedImageTintColor = UIColor.stellaPurple()
        /* self.tabBarController!.tabBar.layer.borderWidth = 0
         self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
         self.tabBarController?.tabBar.clipsToBounds = true */
        
        for item in (tabBarController?.tabBar.items)! {
            item.title = ""
            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
    }
    func prepareViewDidLoad() {
        self.view.backgroundColor = UIColor.mapBackground()
        self.tableView.separatorColor = UIColor.lightGray
        self.tableView.backgroundColor = UIColor.mapBackground()
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.barTintColor = UIColor.mapBackground()
        NotificationCenter.default.addObserver(self, selector: #selector(FriendListViewController.closeImageView), name: NSNotification.Name(rawValue: "closeImageView"), object: nil)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        self.profileView = (Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)?[0] as! ProfileView)
        self.settingView = (Bundle.main.loadNibNamed("SettingView", owner: self, options: nil)?[0] as! SettingView)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        gripperView.layer.cornerRadius = 2.5
        gripperView.backgroundColor = UIColor.mapBackground()
        
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(FriendListViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        searchBar.delegate = self
        buttomHeight = topView.frame.size.height+searchView.frame.size.height
        
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FriendListViewController.tapTopView)))
        
        self.grayView.frame = self.view.frame
        self.grayView.alpha = 0.0
        self.grayView.backgroundColor = UIColor.init(white: 0.34, alpha: 0.5)
        self.grayView.isUserInteractionEnabled = true
        self.grayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FriendListViewController.closeView)))
        
        self.settingView?.center = self.view.center
        self.settingView?.alpha = 0.0
        self.settingView?.block.addTarget(self, action: #selector(FriendListViewController.blockUser), for: .touchUpInside)
        self.settingView?.editName.addTarget(self, action: #selector(FriendListViewController.finishEditName), for: .touchUpInside)
        self.settingView?.cancel.addTarget(self, action: #selector(FriendListViewController.closeView), for: .touchUpInside)
        self.settingView?.isHidden = true
        
        self.profileView?.center = self.view.center
        self.profileView?.alpha = 0.0
        
        
        profileView?.close.addTarget(self, action: #selector(FriendListViewController.closeView), for: .touchUpInside)
        profileView?.close.setImage(UIImage(named: "Delete")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        profileView?.setting.addTarget(self, action: #selector(FriendListViewController.tapSetting), for: .touchUpInside)
        profileView?.setting.setImage(UIImage(named: "Settings")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        profileView?.setting.imageView?.contentMode = .scaleAspectFit
        profileView?.location.addTarget(self, action: #selector(FriendListViewController.showLocation), for: .touchUpInside)
        profileView?.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FriendListViewController.showProfileImage)))
        
        UIApplication.shared.keyWindow?.addSubview(grayView)
        UIApplication.shared.keyWindow?.addSubview(self.profileView!)
        UIApplication.shared.keyWindow?.addSubview(settingView!)
    }
    

}



extension FriendListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
         if userArray.count == 0 {
         self.tableView.separatorStyle = .none
         let label = UILabel()
         label.frame = self.tableView.frame
         label.numberOfLines = 0
         label.lineBreakMode = .byWordWrapping
         label.text = "Your friend list is empty 😢\n\n Try to add someone! 😘"
         label.textAlignment = NSTextAlignment.center
         label.textColor = UIColor.gray
         label.sizeToFit()
         self.tableView.backgroundView = label
         return 0
         }
         else {
        self.tableView.backgroundView = nil
         return 1
         }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if searchActive {
         return searchArray.count
         }
         return userArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendListTableViewCell
        cell.num = indexPath.row
        print("NAme \(userArray[indexPath.row].editName)")
        if userArray[indexPath.row].editName == "" {
            cell.name.text = userArray[indexPath.row].username
        }
        else {
            cell.name.text = userArray[indexPath.row].editName
        }
        if searchActive {
         cell.name.text = searchArray[indexPath.row].username
         }
         else {
         cell.name.text = userArray[indexPath.row].username
         }
        //cell.profile.image = UIImage(named: "trump")
        if cell.accessory.gestureRecognizers?[0] == nil {
            cell.accessory.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FriendListViewController.showProfile)))
        }
        if let img = FriendListViewController.imageCache.object(forKey: NSString(string: userArray[indexPath.row].id)) {
            print("check img \(img)")
            cell.configureCell(user: userArray[indexPath.row],img: img)
        } else {
            print("img is not good \( FriendListViewController.imageCache)")
            cell.configureCell(user: userArray[indexPath.row])
        }

        cell.accessory.tag = indexPath.row
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.frame = CGRect(x:0,y:(self?.defaultMaxY!)!,width: (self?.view.frame.width)!, height:(self?.view.frame.height)!)
        }
        print("check lat long2 \(userArray[indexPath.row].location)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tapFriendLocation"), object: nil, userInfo: ["data":userArray[indexPath.row]])
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            activity.backgroundColor = self.grayView.backgroundColor
            activity.activityIndicatorViewStyle = .whiteLarge
            self.grayView.addSubview(activity)
            activity.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {_ in self.grayView.alpha = 1.0})
            FIRDatabase.database().reference().child("Users/\(currentUser.id)/FriendList/\(userArray[indexPath.row].id)").removeValue(completionBlock: {(error,refer) in
                if error != nil {
                    for view in self.grayView.subviews {
                        if view.isKind(of: UIActivityIndicatorView.self) {
                            view.removeFromSuperview()
                        }
                    }
                    activity.stopAnimating()
                    self.grayView.alpha = 0.0
                    let alert = UIAlertController(title: "Error", message: "Cannot block this person, please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                else {
                    for view in self.grayView.subviews {
                        if view.isKind(of: UIActivityIndicatorView.self) {
                            view.removeFromSuperview()
                        }
                    }
                    activity.stopAnimating()
                    self.grayView.alpha = 0.0
                }
            })
            
        }
    }

}




extension FriendListViewController:UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.view.frame = CGRect(x: 0, y: viewHeight!-3.8*viewHeight!/4.0, width: self!.view.frame.width, height: (self?.view.frame.height)!)
        })
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        searchArray = userArray.filter({ (text) -> Bool in
            let tmp: NSString = text.username as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(searchText == ""){
            searchActive = false;
        } else {
            searchActive = true;
            print(searchArray)
        }
        self.tableView.reloadData()
        
    }
}
extension FriendListViewController:UIGestureRecognizerDelegate {
    func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let y = self.view.frame.minY
        let minimumY = viewHeight!-viewHeight!*3.8/4.0
        let thresholdMinY = viewHeight!/4.6
        let thresholdMaxY = viewHeight!/1.4
        let middleY = viewHeight!/2.0
        self.view.endEditing(true)
        if (y+translation.y) <= viewHeight!-tabbarHeight! && (y+translation.y) >= minimumY {
            let direction = recognizer.velocity(in: self.view).y
            
            if tableView.contentOffset.y == 0 || (y+translation.y) >= minimumY  {
                if  (y+translation.y) >= thresholdMinY && direction > 0  {
                    if recognizer.state == .ended || recognizer.state == .changed  {
                        UIView.animate(withDuration: 0.3) { [weak self] in
                            self?.view.frame = CGRect(x:0,y:(self?.defaultMaxY!)!,width: (self?.view.frame.width)!, height:(self?.view.frame.height)!)
                        }
                    }
                    else {
                        self.view.frame = CGRect(x:0,y:y+translation.y,width: (self.view.frame.width), height:(self.view.frame.height))
                    }
                }
                else if (y+translation.y) <= thresholdMaxY && direction < 0{
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.view.frame = CGRect(x:0,y:minimumY,width: (self?.view.frame.width)!, height:(self?.view.frame.height)!)
                        self?.tableView.isScrollEnabled = true
                        self?.touchSearchView = false
                    }
                }
                else {
                    if recognizer.state == .ended {
                        if (y+translation.y) > middleY {
                            self.view.frame = CGRect(x:0,y:defaultMaxY!,width: (self.view.frame.width), height:(self.view.frame.height))
                        }
                        else {
                            self.view.frame = CGRect(x:0,y:minimumY,width: (self.view.frame.width), height:(self.view.frame.height))
                        }
                    }
                    else {
                        self.view.frame = CGRect(x:0,y:y+translation.y,width: (self.view.frame.width), height:(self.view.frame.height))
                    }
                }
            }
            
            
            
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /* if searchBar.isFocused == true {
         return false
         } */
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let ymin = view.frame.minY
        if (ymin >= (viewHeight!-viewHeight!*3.8/4.0) && direction > 0 && self.tableView.contentOffset.y <= 0) {
            self.tableView.isScrollEnabled = false
        } else {
            self.tableView.isScrollEnabled = true
        }
        
        return false
    }

}

