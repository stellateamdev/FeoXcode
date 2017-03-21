//
//  NotificationTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/9/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import ZAlertView
class NotificationTableViewController: UITableViewController {
    var activityArray:[ActivityData] = []
    var timeArray:[NSDate] = []
    let refresh = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
         self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViewDidLoad()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        } else {
            tableView.addSubview(refresh)
        }
        refresh.addTarget(self, action: #selector(NotificationTableViewController.refreshNotification), for: .valueChanged)
        refresh.tintColor = UIColor.stellaPurple()
        self.queryNotification()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func refreshNotification() {

            let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
            connectedRef.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                    print("Connected")
                    self.queryNotification()
                } else {
                    self.refresh.endRefreshing()
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
    func queryNotification(){
        self.activityArray.removeAll()
        self.timeArray.removeAll()
        let scoresRef = FIRDatabase.database().reference(withPath: "Users/\(currentUser.id)/Notification")
        scoresRef.keepSynced(true)
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Notification").observeSingleEvent(of: .value, with: {(snap) in
            if snap.exists(){
                let data = snap.value as! NSDictionary
                var i = 0
                for dat in data {
                    print(dat.value)
                    let value = dat.value as! NSDictionary
                    if value["Request"] != nil {
                        let act = ActivityData(title: "toRequestActivity")
                        act.creator = value["Request"] as! String
                        act.id = value["uid"] as! String
                        act.pictureURL = value["thumbnailURL"] as! String
                        self.activityArray.append(act)
                        self.timeArray.append(NSDate(timeIntervalSince1970: value["Time"] as! Double))
                        self.sort()
                        i = i+1
                        if i == data.count {
                            self.tableView.reloadData()
                            self.refresh.endRefreshing()
                        }
                    }else{
                        let key = value["Activity"] as! String
                        FIRDatabase.database().reference().child("Activities/\(key)").observeSingleEvent(of: .value, with: {(snap) in
                            if snap.exists() {
                                let dict = snap.value as! NSDictionary
                                let time = dict["enddate"] as! String
                                let date = NSDate(timeIntervalSince1970: Double(time)!)
                                let timeChecker = NSDate().timeIntervalSince(date as Date)
                                print(timeChecker)
                                if timeChecker >= 0 {
                                    FIRDatabase.database().reference().child("Activities/\(key)").removeValue()
                                    FIRDatabase.database().reference().child("Users/\(currentUser.id)/Activities/\(key)").removeValue()
                                    FIRDatabase.database().reference().child("Users/\(currentUser.id)/Notification/\(key)").removeValue()
                                }else{
                                    let acdata = ActivityData()
                                    acdata.location = CLLocationCoordinate2D(latitude: Double(dict["latitude"] as! String)!, longitude: Double(dict["longitude"] as! String)!)
                                    acdata.locationAddress = (dict["locationaddress"] as! String)
                                    acdata.startdateText = (dict["startdatetext"] as! String)
                                    acdata.enddateText = (dict["enddatetext"] as! String)
                                    acdata.title = dict["title"] as! String
                                    acdata.description = (dict["description"] as! String)
                                    acdata.pictureURL = (dict["thumbnailURL"] as! String)
                                    acdata.creator = (dict["username"] as! String)
                                    acdata.id = (dict["uid"] as! String)
                                    acdata.key = (dict["key"] as! String)
                                    self.activityArray.append(acdata)
                                    let t = dict["enddate"] as! String
                                    self.timeArray.append(NSDate(timeIntervalSince1970:  Double(t)!))
                                    self.sort()
                                    i+=1
                                    if i == data.count {
                                        self.tableView.reloadData()
                                        self.refresh.endRefreshing()
                                    }
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
                                    
                                }
                            }else{
                                FIRDatabase.database().reference().child("Users/\(currentUser.id)/Notification/\(key)").removeValue()
                                self.refresh.endRefreshing()
                            }
                        })
                    }
                }
            }
        })
    }
    
    func sort(){
        if self.timeArray.count < 2{
            return
        }
        let max = self.timeArray.count-1
        for var i in (0..<self.timeArray.count-1){
            if self.timeArray[max-i].timeIntervalSince1970 > self.timeArray[max-(i+1)].timeIntervalSince1970{
                self.timeArray = swap(array:self.timeArray, i:max-i ,j: max-(i+1)) as! [NSDate]
                self.activityArray = swap(array:self.activityArray, i:max-i ,j: max-(i+1)) as! [ActivityData]
                self.tableView.reloadData()
            }else{
                break
            }
        }
        self.refresh.endRefreshing()
    }
    
    func swap( array:[Any] , i:Int , j:Int) -> [Any]{
        var array = array
        let temp = array[i]
        array[i] = array[j]
        array[j] = temp
        return array
    }
    func prepareViewDidLoad() {
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.isOpaque = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),for:.default)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.stellaPurple()
        self.navigationItem.title = "Notification"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.items?[2].badgeValue = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if activityArray.count == 0 {
            self.tableView.separatorStyle = .none
            let label = UILabel()
            label.frame = self.tableView.frame
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = "Your Notification is empty"
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activityArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notification", for: indexPath) as! NotificationTableViewCell
        let act = activityArray[indexPath.row]
        var str = NSMutableAttributedString()
        if act.title == "toRequestActivity" {
            str = str.bold("\(act.creator)").normal(" has added you.")
            cell.notiDetail.attributedText = str
            cell.configureCell(uid: act.id)
        }else{
            str = str.bold("\(act.creator)").normal(" has created an activity.")
            cell.notiDetail.attributedText = str
            cell.configureCell(uid: act.id)
        }
        print("\(act.id) LOL>OLOL \(indexPath.row)")
        cell.time.text = "\(DateFormatter().timeSince(from: self.timeArray[indexPath.row]))"
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if activityArray[indexPath.row].title == "toRequestActivity"{
            self.tableView.deselectRow(at: indexPath, animated: false)
            let view = self.storyboard?.instantiateViewController(withIdentifier: "friendRequest") as! FriendRequestViewController
            self.navigationController?.pushViewController(view, animated: true)
        }else{
            self.tableView.deselectRow(at: indexPath, animated: false)
            let view = self.storyboard?.instantiateViewController(withIdentifier: "viewActivity") as! ViewActivityTableViewController
            view.data = activityArray[indexPath.row]
            self.navigationController?.pushViewController(view, animated: true)
        }
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
extension NSMutableAttributedString {
    func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 16)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    func normal(_ text:String)->NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 16)!]
        let normal = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(normal)
        return self
    }
}

extension DateFormatter {
    /**
     Formats a date as the time since that date (e.g., “Last week, yesterday, etc.”).
     
     - Parameter from: The date to process.
     - Parameter numericDates: Determines if we should return a numeric variant, e.g. "1 month ago" vs. "Last month".
     
     - Returns: A string with formatted `date`.
     */
    func timeSince(from: NSDate, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 2 {
            result = "\(components.year!) years ago"
        } else if components.year! >= 1 {
            if numericDates {
                result = "1 year ago"
            } else {
                result = "Last year"
            }
        } else if components.month! >= 2 {
            result = "\(components.month!) months ago"
        } else if components.month! >= 1 {
            if numericDates {
                result = "1 month ago"
            } else {
                result = "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            result = "\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                result = "1 week ago"
            } else {
                result = "Last week"
            }
        } else if components.day! >= 2 {
            result = "\(components.day!) days ago"
        } else if components.day! >= 1 {
            if numericDates {
                result = "1 day ago"
            } else {
                result = "Yesterday"
            }
        } else if components.hour! >= 2 {
            result = "\(components.hour!) hours ago"
        } else if components.hour! >= 1 {
            if numericDates {
                result = "1 hour ago"
            } else {
                result = "An hour ago"
            }
        } else if components.minute! >= 2 {
            result = "\(components.minute!) minutes ago"
        } else if components.minute! >= 1 {
            if numericDates {
                result = "1 minute ago"
            } else {
                result = "A minute ago"
            }
        } else if components.second! >= 3 {
            result = "\(components.second!) seconds ago"
        } else {
            result = "Just now"
        }
        
        return result
    }
}
