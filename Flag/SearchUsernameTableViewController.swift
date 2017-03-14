//
//  SearchUsernameTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/1/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import OneSignal
import ZAlertView
class SearchUsernameTableViewController: UITableViewController {
    let searchBar = UISearchBar()
    var searchArray:[User] = []
    let label = UILabel()
    let addButton = UIButton()
    var isSearch = false
    var searchFinish = false
    var addCell:SearchUsernameTableViewCell!
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Add by Username"
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.tableView.separatorInset = UIEdgeInsets.zero
        searchBar.barTintColor = UIColor.white
        searchBar.delegate = self
        addButton.tintColor = UIColor.white
        
        addButton.setTitle("+", for: .normal)
        addButton.backgroundColor = UIColor.stellaPurple()
        addButton.addTarget(self, action: #selector(SearchUsernameTableViewController.addFriend), for: .touchUpInside)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)!]
        searchBar.placeholder = "Search with Username"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        searchBar.delegate = self
        FIRDatabase.database().reference().child("Users/\(currentUser.id)").observeSingleEvent(of: .value, with: {snap in
            if snap.value != nil {
            let dictionary = snap.value as! [String:AnyObject]
            self.label.text = "Your username is \(dictionary["username"]!) 😃"
            }
        })
        label.frame = CGRect.init(x:0, y:0, width:50, height: 50)
      
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.gray
        label.sizeToFit()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addFriend(sender:UIButton) {
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
        if sender.currentTitle! == "Added" {
            return
        }
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        activity.startAnimating()
        let cell = tableView.cellForRow(at: NSIndexPath(row: sender.tag+1, section: 0) as IndexPath) as! SearchUsernameTableViewCell

        self.tableView.reloadData()
        FIRDatabase.database().reference().child("Users/\(searchArray[sender.tag].id)/Friendrequest").queryEqual(toValue: currentUser.id).observeSingleEvent(of: .value, with: { snap in
            if !(snap.value is NSNull) {
            let dictionary = snap.value as! [String:String]
                for value in dictionary {
                    let dict = value.value
                    if dict == currentUser.id {
                        FIRDatabase.database().reference().child("Users/\(self.searchArray[sender.tag].id)/Friendrequest/\(currentUser.id)").removeValue()
                        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Friendlist)").updateChildValues(["\(self.searchArray[sender.tag].id)" : self.searchArray[sender.tag].username])
                        FIRDatabase.database().reference().child("Users/\(self.searchArray[sender.tag].id)/Friendlist").updateChildValues([currentUser.id:currentUser.id])
                        OneSignal.postNotification(["contents": ["en": "\(currentUser.username) sent you a friend request"], "include_player_ids": ["\(self.searchArray[sender.tag].oneid)"]])
                        FIRDatabase.database().reference().child("Users/\(self.searchArray[sender.tag].id)/Notification").childByAutoId().updateChildValues([ "Request" : self.searchArray[sender.tag].username,"Time" :
                            NSDate().timeIntervalSince1970,"thumbnailURL" : currentUser.thumbnailURL,"uid":self.searchArray[sender.tag].id])
                        self.tableView.reloadData()
                        activity.stopAnimating()
                    }
                }
            }
            else {
                FIRDatabase.database().reference().child("Users/\(self.searchArray[sender.tag].id)/Friendrequest").updateChildValues([currentUser.id:currentUser.id])
                FIRDatabase.database().reference().child("Users/\(self.searchArray[sender.tag].id)/Friendlist").updateChildValues([self.searchArray[sender.tag].id:self.searchArray[sender.tag].id])
                activity.stopAnimating()
            }
        }) // remove b req
         // add a frd
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchArray.count > 0 {
           
            return searchArray.count + 1
        }
        else {
  
        return 2
        }
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.row == 0 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "addUsername", for: indexPath)
            searchBar.frame = CGRect.init(x: 0, y: 0, width: cell.frame.size.width , height: 51)
            //addButton.frame = CGRect.init(x: cell.frame.size.width - 50, y: 0, width: 50, height: 51)
            cell.addSubview(searchBar)
            return cell
        }
        else if indexPath.row == 1 {
            if !self.label.isHidden {
             let cell = tableView.dequeueReusableCell(withIdentifier: "addUsername", for: indexPath)
             cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
            cell.backgroundView = label
            return cell
            }
            print("visible cell \(tableView.visibleCells.count)")
            if searchArray.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addUsername", for: indexPath)
                cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
                
                activity.center = cell.contentView.center
                activity.color = UIColor.darkGray
                activity.backgroundColor = UIColor.white
                activity.startAnimating()
                cell.backgroundView = activity
                return cell
            }
            else {
            
                print(searchArray[indexPath.row-1].username)
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchFriend") as! SearchUsernameTableViewCell
                
                 cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
                cell.name.text = searchArray[indexPath.row-1].username
                print("check contain in \(userArray.contains(searchArray[indexPath.row-1]) )")
                for data in userArray {
                    if data == searchArray[indexPath.row-1] {
                    cell.accessory.setTitle("Added", for: .normal)
                    cell.accessory.backgroundColor = UIColor.gray
                    cell.accessory.tintColor = UIColor.darkGray
                }
                }
                cell.accessory.addTarget(self, action: #selector(SearchUsernameTableViewController.addFriend), for: .touchUpInside)
                cell.configureCell(user: searchArray[indexPath.row-1])
                return cell
            }
            
        }
        else {
            print("searcharrayyyyyyyy count")
            print(searchArray[indexPath.row-1].username)
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFriend") as! SearchUsernameTableViewCell
            cell.accessory.tag = indexPath.row-1
            
             cell.accessory.addTarget(self, action: #selector(SearchUsernameTableViewController.addFriend), for: .touchUpInside)
            cell.name.text = searchArray[indexPath.row-1].username
            for data in userArray {
                print("data in \(data.username) \(searchArray[indexPath.row-1])")
                if data == searchArray[indexPath.row-1] {
                    cell.accessory.setTitle("Added", for: .normal)
                    
                    cell.accessory.backgroundColor = UIColor.gray
                    cell.accessory.tintColor = UIColor.darkGray
                }
            }
            cell.configureCell(user: searchArray[indexPath.row-1])
            return cell
        }

        // Configure the cell...

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
extension SearchUsernameTableViewController:UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
        
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchArray.removeAll()
            label.isHidden = false
            activity.stopAnimating()
            self.tableView.reloadData()
            self.searchBar.becomeFirstResponder()
        }
        else {
        searchFriend()
        label.isHidden = true
        }
    }
    func  searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFriend()
        label.isHidden = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchArray.removeAll()
        label.isHidden = false
        activity.stopAnimating()
        self.tableView.reloadData()
        self.searchBar.becomeFirstResponder()
    }
    func searchFriend() {
        self.searchArray.removeAll()
        self.tableView.reloadData()
        self.searchBar.becomeFirstResponder()
        let deadlineTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            
            FIRDatabase.database().reference().child("Users").queryOrdered(byChild: "username").queryEqual(toValue: self.searchBar.text!.lowercased()).observeSingleEvent(of: .value, with: {snap in
                if !(snap.value is NSNull) {
                let dictionary = snap.value as! [String:AnyObject]
                for value in dictionary {
                    let dict = value.value as! [String:AnyObject]
                    self.searchArray.removeAll()
                    let user = User().toDict(user: dict)
                    self.searchArray.append(user)
                    self.searchFinish = true
                    self.tableView.reloadData()
                    }
                }else{
                    self.activity.stopAnimating()
                }
            })
        })
    }
}
