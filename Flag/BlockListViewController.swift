//
//  BlockListTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/10/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import ZAlertView
class BlockListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView:UITableView!
    var activity = UIActivityIndicatorView()
    var blockArray:[User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.tableView.separatorColor = .gray
       self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.title = "Block List"
        self.navigationController?.navigationBar.titleTextAttributes =  [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]
        activity = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.size.width/2.0-30, y: self.view.frame.size.height/2.0-74, width: 60, height: 60))
        activity.layer.cornerRadius = 5
        activity.backgroundColor = UIColor.darkGray
        activity.activityIndicatorViewStyle = .white
      self.tableView.addSubview(activity)
        queryBlockList()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func queryBlockList() {
        let scoresRef = FIRDatabase.database().reference(withPath: "Users/\(currentUser.id)/Blocklist")
        scoresRef.keepSynced(true)
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Blocklist").observe(.value, with: { snap in
            if !snap.exists() {
                print("!snap.exist bitch")
            }
            else {
               print("okokoko")
                let dictionary = snap.value as! NSDictionary
                var index = 0
                for value in dictionary {
                    print("print next1")
                    FIRDatabase.database().reference().child("Users/\(value.value)").observeSingleEvent(of: .value, with: { snap in
                        if snap.exists() {
                            print("print next2 \(snap.value)")
                                index += 1
                                let dict = snap.value as! [String:AnyObject]
                                self.blockArray.append(User(id: (dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String), pictureURL: (dict["pictureURL"] as! String)))
                                self.tableView.reloadData()
                        }
                        else {
                            
                        }
                    })
                }

                }
        })
    }
    
    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if blockArray.count == 0 {
            self.tableView.separatorStyle = .none
            let label = UILabel()
            label.frame = self.tableView.frame
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = "Your block list is empty 😍\n\n That's good 😘"
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
        print("check row \(blockArray.count)")
        return blockArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blocklist", for: indexPath) as! BlockListTableViewCell
        cell.name.text = blockArray[indexPath.row].username
        cell.profile.image = UIImage(named: "trump")
        if cell.accessory.allTargets.count == 0 {
            cell.accessory.addTarget(self, action: #selector(BlockListViewController.remove(sender:)), for: .touchUpInside)
            cell.accessory.tag = indexPath.row
        }
        if let img = FriendListViewController.imageCache.object(forKey: blockArray[indexPath.row].id as NSString) {
            cell.configureCell(user: blockArray[indexPath.row],img: img)
        } else {
            cell.configureCell(user: blockArray[indexPath.row])
        }

        // Configure the cell...

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func remove(sender:UIButton) {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected")
                
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
                return
                
                
                
            }
        })

        let num = sender.tag
        
        self.activity.alpha = 1.0
        self.activity.startAnimating()
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Blocklist/\(blockArray[num].id)").removeValue(completionBlock: {(error,refer) in
            if error != nil {
                self.activity.stopAnimating()
                self.activity.alpha = 0.0
                let alert = UIAlertController(title: "Error", message: "Cannot Unblock this person, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            }
            else {
                self.addToFriendList(num: num)
            }
        })
    }
    func addToFriendList(num:Int) {
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Friendlist/\(blockArray[num].id)").setValue(blockArray[num].id, withCompletionBlock: {(error,ref) in
            if error != nil {
                self.activity.stopAnimating()
                self.activity.alpha = 0.0
                let alert = UIAlertController(title: "Error", message: "Cannot Unblock this person, please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            }
            else {
                 self.blockArray.remove(at: num)
                self.tableView.reloadData()
                self.activity.stopAnimating()
                self.activity.alpha = 0.0
            }
        })
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
