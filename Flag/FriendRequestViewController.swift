//
//  FriendRequestTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/11/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import ZAlertView
class FriendRequestViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var requestArray:[User] = []
    @IBOutlet weak var tableView:UITableView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.title = "Friend Request"
        self.navigationController?.navigationBar.titleTextAttributes =  [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        queryFriendRequest()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func queryFriendRequest() {
        
        let scoresRef = FIRDatabase.database().reference(withPath: "Users/\(currentUser.id)/Friendrequest")
        scoresRef.keepSynced(true)
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Friendrequest").observe(.value, with: { snap in
            if !(snap.value is NSNull){
                let dictionary = snap.value as! [String:String]
                for value in dictionary {
                    let dict = value.value
                    FIRDatabase.database().reference().child("Users/\(dict)").observeSingleEvent(of: .value, with: {snap in
                        let dict = snap.value as! [String:AnyObject]
                        let user = User(id: (dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String), pictureURL: (dict["pictureURL"] as! String))
                        user.phoneNumber = dict["phonenumber"] as! String
                        self.requestArray.append(user)
                            self.tableView.reloadData()
                    })
                    
                }
            }
            else {
                print("no shit at all")
            }
                })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if requestArray.count == 0 {
            self.tableView.separatorStyle = .none
            let label = UILabel()
            label.frame = self.tableView.frame
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = "Your friend request list is empty 😢\n\n Try to add someone first! 😘"
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.gray
            label.sizeToFit()
            self.tableView.backgroundView = label
            return 0
        }
        else {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = nil
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requestArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendrequest", for: indexPath) as! FriendRequestTableViewCell
        cell.name.text = requestArray[indexPath.row].username
        cell.accessory.tag = indexPath.row
        if cell.isAdded {
            cell.accessory.backgroundColor = UIColor.lightGray
            cell.accessory.setTitle("Added", for: .normal)
            cell.accessory.tintColor = UIColor.darkGray
        }
        if cell.accessory.allTargets.count == 0 {
            
            cell.accessory.addTarget(self, action: #selector(FriendRequestViewController.add(sender:)), for: .touchUpInside)
            cell.accessory.tag = indexPath.row
        }
        if let img = FriendListViewController.imageCache.object(forKey: requestArray[indexPath.row].id as NSString) {
            cell.configureCell(user: requestArray[indexPath.row],img: img)
        } else {
           cell.configureCell(user: requestArray[indexPath.row])
        }

        
        // Configure the cell...
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func add(sender:UIButton) {
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
        let cell = tableView.cellForRow(at: NSIndexPath(row: sender.tag, section: 0) as IndexPath) as! FriendRequestTableViewCell
        cell.isAdded = true
        self.tableView.reloadData()
        print("check request array \(requestArray[sender.tag].id)")
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Friendrequest/\(requestArray[sender.tag].id)").removeValue() // remove b req
        
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Friendlist").updateChildValues(["\(requestArray[sender.tag].id)" : requestArray[sender.tag].id]) // add a frd
        
        FIRDatabase.database().reference().child("Users/\(requestArray[sender.tag].id)/Friendlist").setValue([currentUser.id :currentUser.id]) // add b frd 
    }


}
