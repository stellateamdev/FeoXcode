//
//  JoinedActivityTableViewController.swift
//  Flag
//
//  Created by marky RE on 3/18/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import Firebase
class JoinedActivityTableViewController: UITableViewController {

    var joinArray:[ActivityData] = []
    let refresh = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.queryActivities()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        } else {
            tableView.addSubview(refresh)
        }
        refresh.addTarget(self, action: #selector(JoinedActivityTableViewController.reloadData), for: .valueChanged)
        refresh.tintColor = UIColor.stellaPurple()
        NotificationCenter.default.addObserver(self, selector: #selector(JoinedActivityTableViewController.reloadData), name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func reloadData() {
        queryActivities()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
   override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if joinArray.count == 0 {
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
        print("joinarray count \(joinArray.count)")
        return joinArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedActivityCell", for: indexPath) as! JoinedActivityTableViewCell
        cell.title.text = joinArray[indexPath.row].title
        cell.time.text = "\(joinArray[indexPath.row].startdateText) - \(joinArray[indexPath.row].enddateText)"
        let num = joinArray[indexPath.row].join.count
        cell.join.text = "\(num) have joined"
        if let img = ActivityFeedTableViewController.activityImageCache.object(forKey: joinArray[indexPath.row].id as NSString) {
            cell.configureCell(activity: joinArray[indexPath.row], img: img)
        }
        else {
            cell.configureCell(activity: joinArray[indexPath.row])
        }
        // Configure the cell...
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let view = self.storyboard?.instantiateViewController(withIdentifier: "viewActivity") as! ViewActivityTableViewController
        if joinArray[indexPath.row].id == currentUser.id {
            view.created = true
        }
        view.data = joinArray[indexPath.row]
        self.navigationController?.pushViewController(view, animated: true)
    }
    func queryActivities() {
        
        FIRDatabase.database().reference().child("Users/\(FIRAuth.auth()!.currentUser!.uid)/Joins").observe(.value, with: { snap in
            if snap.exists() {
                self.joinArray.removeAll()
                print("snap join is exist")
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
                                                    self.refresh.endRefreshing()
                                                    self.tableView.reloadData()
                                                }
                                            }
                                            //self.activityArray[i].join.append(User(id:(dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String),pictureURL: (dict["pictureURL"] as! String)))
                                            
                                        }
                                    })
                                }
                            }
                            self.refresh.endRefreshing()
                            self.tableView.reloadData()
                        }
                        
                    })
                }
            }
            else {
                 print("snap join doesn't exist")
                self.refresh.endRefreshing()
                self.joinArray.removeAll()
                self.tableView.reloadData()
            }
        })
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
