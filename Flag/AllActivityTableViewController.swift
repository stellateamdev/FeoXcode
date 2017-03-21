//
//  AllActivityTableViewController.swift
//  Flag
//
//  Created by marky RE on 3/18/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import Firebase
class AllActivityTableViewController: UITableViewController {
    let refresh = UIRefreshControl()
    var activityArray:[ActivityData] = []
    
    static var activityImageCache: NSCache<NSString, UIImage> = NSCache()
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
     self.queryActivities()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func prepareView() {
         self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        } else {
            tableView.addSubview(refresh)
        }
        refresh.addTarget(self, action: #selector(AllActivityTableViewController.refreshActivity), for: .valueChanged)
        refresh.tintColor = UIColor.stellaPurple()
        print("fuck width \(self.tableView.frame.size.width)")
        NotificationCenter.default.addObserver(self, selector: #selector(AllActivityTableViewController.refreshActivity), name: NSNotification.Name(rawValue: "reloadTableActivity"), object: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func refreshActivity() {
        queryActivities()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if activityArray.count == 0 {
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
            self.tableView.separatorStyle = .singleLine
            return 1
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activityArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllActivityCell", for: indexPath) as! AllActivityTableViewCell
        cell.title.text = activityArray[indexPath.row].title
        cell.time.text = "\(activityArray[indexPath.row].startdateText) - \(activityArray[indexPath.row].enddateText)"
        let num = activityArray[indexPath.row].join.count
        cell.join.text = "\(num) have joined"
        if let img = ActivityFeedTableViewController.activityImageCache.object(forKey: activityArray[indexPath.row].id as NSString) {
            cell.configureCell(activity: activityArray[indexPath.row], img: img)
        }
        else {
            cell.configureCell(activity: activityArray[indexPath.row])
        }
        // Configure the cell...
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let view = self.storyboard?.instantiateViewController(withIdentifier: "viewActivity") as! ViewActivityTableViewController
        if activityArray[indexPath.row].id == currentUser.id {
            view.created = true
        }
        view.data = activityArray[indexPath.row]
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func queryActivities() {
        let scoresRef = FIRDatabase.database().reference(withPath: "Users/\(FIRAuth.auth()!.currentUser!.uid)/Activities")
        scoresRef.keepSynced(true)
        
        FIRDatabase.database().reference().child("Users/\(FIRAuth.auth()!.currentUser!.uid)/Activities").observeSingleEvent(of: .value, with: { snap in
            if snap.exists() {
                print("snap is indeed exist 12345")
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
                                self.activityArray.append(ActivityData(location: CLLocationCoordinate2D(latitude: Double(dict["latitude"] as! String)!, longitude: Double(dict["longitude"] as! String)!), locationAddress: (dict["locationaddress"] as! String),  startdateText: (dict["startdatetext"] as! String),enddateText: (dict["enddatetext"] as! String), title: (dict["title"] as! String), description: (dict["description"] as! String), pictureURL: (dict["pictureURL"] as! String),creator:(dict["username"] as! String),id:(dict["uid"] as! String),key:(dict["key"] as! String)))
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
                                self.refreshControl?.endRefreshing()
                                self.tableView.reloadData()
                            }
                        }else{
                            FIRDatabase.database().reference().child("Users/\(currentUser.id)/Activities/\(key)").removeValue()
                            self.refreshControl?.endRefreshing()
                        }
                        
                    })
                }
                
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }else{
                print("damn snap is empty")
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
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
