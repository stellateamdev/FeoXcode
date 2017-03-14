//
//  ActivityFeedTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/5/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import ZAlertView
class ActivityFeedTableViewController:UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView:UITableView!
    var activityArray:[ActivityData] = []
    private let refreshControl = UIRefreshControl()
    static var activityImageCache: NSCache<NSString, UIImage> = NSCache()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        queryActivities()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(UserActivityTableViewController.refreshActivity), for: .valueChanged)
        refreshControl.tintColor = UIColor.stellaPurple()
        print("fuck width \(self.tableView.frame.size.width)")
        NotificationCenter.default.addObserver(self, selector: #selector(ActivityFeedTableViewController.reloadData), name: NSNotification.Name(rawValue: "reloadTableActivity"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can bƒe recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        print("enter didappear")
        self.tabBarController?.tabBar.isHidden = false
    }
    func reloadData() {
        print("queryactivities reload")
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
        let scoresRef = FIRDatabase.database().reference(withPath: "Users/\(currentUser.id)/Activities")
        scoresRef.keepSynced(true)
       
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Activities").observeSingleEvent(of: .value, with: { snap in
            if snap.exists() {
                
                self.activityArray.removeAll()
                self.tableView.reloadData()
                let dictionary = snap.value as! NSDictionary
                for value in dictionary {
                    print("value for activity \(value.value)")
                    let key = value.value as! String
                    FIRDatabase.database().reference().child("Activities/\(key)").observeSingleEvent(of: .value, with: { snap in
                        if snap.exists() {
                            let dict = snap.value as! NSDictionary
                            let time = dict["enddate"] as! String
                            let date = NSDate(timeIntervalSince1970: Double(time)!)
                            let timeChecker = NSDate().timeIntervalSince(date as Date)
                            if timeChecker >= 0 {
                                FIRDatabase.database().reference().child("Activities/\(key)").removeValue()
                                FIRDatabase.database().reference().child("Users/\(currentUser.id)/Activities/\(key)").removeValue()
                            }else{
                                print("avgconsumer \((dict["locationaddress"] as! String)) ")
                                self.activityArray.append(ActivityData(location: CLLocationCoordinate2D(latitude: Double(dict["latitude"] as! String)!, longitude: Double(dict["longitude"] as! String)!), locationAddress: (dict["locationaddress"] as! String),  startdateText: (dict["startdatetext"] as! String),enddateText: (dict["enddatetext"] as! String), title: dict["title"] as! String, description: (dict["description"] as! String), pictureURL: (dict["pictureURL"] as! String),creator:(dict["username"] as! String),id:(dict["uid"] as! String),key:(dict["key"] as! String)))
                                let join = dict["Join"] as? NSDictionary
                                if join != nil{
                                    for participant in join! {
                                        FIRDatabase.database().reference().child("Users/\(participant.value)").observeSingleEvent(of: .value, with: { snap in
                                            if snap.exists() {
                                                //print("print i \(i)")
                                                for i in 0...self.activityArray.count-1 {
                                                    if self.activityArray[i].key == dict["key"] as! String{
                                                        let dict = snap.value as! NSDictionary
                                                        self.activityArray[i].join.append(User(id:(dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String),pictureURL: (dict["pictureURL"] as! String)))
                                                    }
                                                }
                                                let dict = snap.value as! NSDictionary
                                                //self.activityArray[i].join.append(User(id:(dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String),pictureURL: (dict["pictureURL"] as! String)))
                                                
                                            }
                                        })
                                    }
                                }
                               self.refreshControl.endRefreshing()
                                self.tableView.reloadData()
                            }
                        }else{
                            FIRDatabase.database().reference().child("Users/\(currentUser.id)/Activities/\(key)").removeValue()
                            self.refreshControl.endRefreshing()
                        }
                        
                    })
                }
                
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }else{
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
          
        })
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
        return activityArray.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityFeed", for: indexPath) as! ActivityFeedTableViewCell
        cell.label.text = activityArray[indexPath.row].title
        cell.queryLocation(loc: activityArray[indexPath.row].location)   
       // cell.location.attributedText = cell.addAttributedText(text: activityArray[indexPath.row].locationAddress)
       // cell.location.text = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.."//   42 fullactivityArray[indexPath.row].locationAddress
        cell.sub.text = "Created by \(activityArray[indexPath.row].creator)"
        cell.detail.text = activityArray[indexPath.row].description
        print("cellcellcellcell \(cell.location.frame.maxX) \(self.tableView.frame.size.width) ")
      /*  if (cell.label.text?.characters.count)! >= 40 {
            let title = activityArray[indexPath.row].title
            let index = title.index(title.startIndex, offsetBy: 36)
            cell.label.text = title.substring(to: index)
        }
        if (cell.sub.text?.characters.count)! >= 40 {
            let title = activityArray[indexPath.row].description
            let index = title.index(title.startIndex, offsetBy: 36)
            cell.sub.text = title.substring(to: index)
        }
        if (cell.location.text?.characters.count)! >= 40{
            let title = activityArray[indexPath.row].locationAddress
            let index = title.index(title.startIndex, offsetBy: 37)
            
            cell.location.text = "\(title.substring(to: index)).."
            print("cell.locaton.text \(cell.location.text)")
        } */

        print("fuck this shit width motherfucker \(cell.label.frame.size.width) \(cell.location.frame.size.width)")
        if let img = ActivityFeedTableViewController.activityImageCache.object(forKey: activityArray[indexPath.row].id as NSString) {
            cell.configureCell(activity: activityArray[indexPath.row], img: img)
        }
        else {
            cell.configureCell(activity: activityArray[indexPath.row])
        }
        print("offset \(tableView.frame.minY) \(self.view.frame.minY)")
        // Configure the cell...

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.tableView.deselectRow(at: indexPath, animated: false)
        let view = self.storyboard?.instantiateViewController(withIdentifier: "viewActivity") as! ViewActivityTableViewController
        if activityArray[indexPath.row].id == currentUser.id {
            view.created = true
        }
        view.data = activityArray[indexPath.row]
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
