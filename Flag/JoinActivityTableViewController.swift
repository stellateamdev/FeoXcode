//
//  JoinActivityTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/5/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import ZAlertView
class JoinActivityTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView:UITableView!
    var joinArray:[ActivityData] = []
     private let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.queryActivities()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(UserActivityTableViewController.refreshActivity), for: .valueChanged)
        refreshControl.tintColor = UIColor.stellaPurple()
         NotificationCenter.default.addObserver(self, selector: #selector(JoinActivityTableViewController.reloadData), name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func reloadData() {
        queryActivities()
    }
    func refreshActivity() {
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected")
                self.queryActivities()
            } else {
                self.refreshControl.endRefreshing()
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
        
    }
    func queryActivities() {
       
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Joins").observe(.value, with: { snap in
            if snap.exists() {
                self.joinArray.removeAll()
                let dictionary = snap.value as! NSDictionary
                for value in dictionary {
                    print("value for activity \(value.value)")
                    let key = value.value as! String
                    FIRDatabase.database().reference().child("Activities/\(key)").observeSingleEvent(of: .value, with: { snap in
                        if snap.exists() {
                            let dict = snap.value as! NSDictionary
                            print("avgconsumer \((dict["locationaddress"] as! String)) ")
                            self.joinArray.append(ActivityData(location: CLLocationCoordinate2D(latitude: Double(dict["latitude"] as! String)!, longitude: Double(dict["longitude"] as! String)!), locationAddress: (dict["locationaddress"] as! String),  startdateText: (dict["startdatetext"] as! String),enddateText: (dict["enddatetext"] as! String), title: dict["title"] as! String, description: (dict["description"] as! String), pictureURL: (dict["pictureURL"] as! String),creator:(dict["username"] as! String),id:(dict["uid"] as! String),key:(dict["key"] as! String)))
                            let join = dict["Join"] as? NSDictionary
                            if join != nil {
                                for participant in join! {
                                    FIRDatabase.database().reference().child("Users/\(participant.value)").observeSingleEvent(of: .value, with: { snap in
                                        if snap.exists() {
                                            //print("print i \(i)")
                                            for i in 0...self.joinArray.count-1 {
                                                if self.joinArray[i].key == dict["key"] as! String{
                                                    let dict = snap.value as! NSDictionary
                                                    self.joinArray[i].join.append(User(id:(dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String),pictureURL: (dict["pictureURL"] as! String)))
                                                    self.refreshControl.endRefreshing()
                                                    self.tableView.reloadData()
                                                }
                                            }
                                            //self.activityArray[i].join.append(User(id:(dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String),pictureURL: (dict["pictureURL"] as! String)))
                                            
                                        }
                                    })
                                }
                            }
                             self.refreshControl.endRefreshing()
                            self.tableView.reloadData()
                        }
                        
                    })
                }
            }
            else {
                self.refreshControl.endRefreshing()
                self.joinArray.removeAll()
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if userArray.count == 0 {
            self.tableView.separatorStyle = .none
            let label = UILabel()
            label.frame = self.tableView.frame
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = "No Activity"
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
        // #warning Incomplete implementation, return the number of rows
        return joinArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "joinActivity", for: indexPath) as! JoinActivityTableViewCell
        cell.label.text = joinArray[indexPath.row].title
        cell.queryLocation(loc: joinArray[indexPath.row].location)
        cell.sub.text = "Created by \(joinArray[indexPath.row].creator)"
        cell.detail.text = joinArray[indexPath.row].description
        // Configure the cell...
        if let img = ActivityFeedTableViewController.activityImageCache.object(forKey: joinArray[indexPath.row].id as NSString) {
            cell.configureCell(activity: joinArray[indexPath.row], img: img)
        }
        else {
            cell.configureCell(activity: joinArray[indexPath.row])
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let view = self.storyboard?.instantiateViewController(withIdentifier: "viewActivity") as! ViewActivityTableViewController
        view.data = joinArray[indexPath.row]
        self.navigationController?.pushViewController(view, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
