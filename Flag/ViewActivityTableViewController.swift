//
//  ViewActivityTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/18/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import MapKit
import OneSignal
import Firebase

class ViewActivityTableViewController: UITableViewController {
    var data = ActivityData()
    var created = false
    @IBOutlet weak var mapView:MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationItem.title = data.title
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)!]
        //self.tableView.frame = CGRect(x: 0, y: -50, width: self.tableView.frame.size.width, height: self.tableView.frame.size.height)
        self.tableView.separatorColor = UIColor.init(white: 0.5, alpha: 0.15)
        self.automaticallyAdjustsScrollViewInsets = false
        mapView = tableView.tableHeaderView as! MKMapView!
        tableView.tableHeaderView = nil
        tableView.addSubview(mapView)
        tableView.sendSubview(toBack: mapView)
        tableView.contentInset = UIEdgeInsetsMake(175, 0, 0, 0)
        tableView.contentOffset = CGPoint(x: 0, y: -175)
        self.tableView.backgroundColor = UIColor.init(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        self.automaticallyAdjustsScrollViewInsets = false
        mapView.frame = CGRect(x: 0, y: -175, width: tableView.bounds.width, height: 175)
        let span = MKCoordinateSpanMake(0.003125, 0.003125)
        let region = MKCoordinateRegion(center: data.location, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = data.location
        mapView.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    func updateHeaderView() {
        var scaleFactor:CGFloat = 0.0

        if tableView.contentOffset.y < -175 {

            scaleFactor = -tableView.contentOffset.y/175
            
             print(" --- \(tableView.contentOffset.y) \(scaleFactor)")
             self.mapView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                    mapView.frame.origin.y = tableView.contentOffset.y
        }
        else {
            self.mapView.transform = CGAffineTransform(scaleX: 1 , y:1)
            mapView.frame = CGRect(x: 0, y: -175, width: tableView.bounds.width, height: 175)
        }
       
    }
    
    func clickJoin(sender:UIButton) {
        if sender.tag == 0 {
            sender.setAttributedTitle(NSAttributedString(string: "Joined", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!]), for: .normal)
            sender.backgroundColor = UIColor.stellaPurple()
            sender.tag = 1
            joinActivity()
        }
        else {
            sender.setAttributedTitle(NSAttributedString(string: "Join", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!]), for: .normal)
            sender.backgroundColor = UIColor.gray
            sender.tag = 0
            dejoinActivity()
        }
    }
    
    func joinActivity() {
        FIRDatabase.database().reference(withPath: "Activities/\(data.key)/Join").updateChildValues([currentUser.id:currentUser.id])
        FIRDatabase.database().reference(withPath: "Users/\(currentUser.id)/Joins").updateChildValues([data.key:data.key])
        
            FIRDatabase.database().reference().child("Users/\(currentUser.id)").observeSingleEvent(of: .value, with: { snap in
                if snap.exists() {
                    //print("print i \(i)")
                    for user in userArray {
                        print("LOL \(user.oneid)")
                        OneSignal.postNotification(["contents": ["en": "\(currentUser.username) has join activity"], "include_player_ids": ["\(user.oneid)"]])
                        FIRDatabase.database().reference().child("Users/\(user.id)/Notification").updateChildValues([ "Activity" : self.data.key])
                    }
                        let dict = snap.value as! NSDictionary
                        self.data.join.append(User(id:(dict["uid"] as! String), oneid: (dict["oneid"] as! String), username: (dict["username"] as! String), email: (dict["email"] as! String),pictureURL: (dict["pictureURL"] as! String)))
                      NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadTable")))
                    self.tableView.reloadData()
                }
        })
        
    }
    func dejoinActivity() {
        FIRDatabase.database().reference(withPath: "Activities/\(data.key)/Join/\(currentUser.id)").removeValue()
                FIRDatabase.database().reference(withPath: "Users/\(currentUser.id)/Joins/\(data.key)").removeValue()
        for i in 0...data.join.count-1{
            if data.join[i].id == currentUser.id {
                data.join.remove(at: i)
                  NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadTable")))
                 self.tableView.reloadData()
                return
            }
        }
    }
    func removeActivity() {
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0-194)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        activity.startAnimating()
        self.tableView.addSubview(activity)
        self.tableView.bringSubview(toFront: activity)
        FIRDatabase.database().reference().child("Activities/\(data.key)").removeValue(completionBlock: {(error, refer) in
            if error == nil {
                FIRDatabase.database().reference().child("Users/\(currentUser.id)/Activities/\(self.data.key)").removeValue(completionBlock: {(error,refer) in
                    if error == nil {
                                      NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadTableCreated")))
                         NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadTableActivity")))
                        activity.stopAnimating()
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        })
        

        //NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadTableActivity")))
        

       // self.navigationController?.popViewController(animated: true)
    }
    func toMap() {
       let ac = UIAlertController(title: "Open in ", message: "choose your options", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Open in Apple Map", style: .default, handler: {_ in
                UIApplication.shared.openURL(NSURL(string:
                    "http://maps.apple.com/?daddr=\(self.data.location.latitude),\(self.data.location.longitude)&directionsmode=driving")! as URL)
           
        }))
        ac.addAction(UIAlertAction(title: "Open in Google Map", style: .default, handler: {_ in
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                UIApplication.shared.openURL(NSURL(string:
                    "comgooglemaps://?saddr=&daddr=\(self.data.location.latitude),\(self.data.location.longitude)&directionsmode=driving")! as URL)
                
            } else {
                NSLog("Can't use comgooglemaps://");
            }
        }))
          ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler:nil))
            
        self.present(ac, animated: true, completion: nil)
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height:10))
        view.backgroundColor = UIColor.RGB(r: 247, g: 247, b: 247)
        return view
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 60
            }
            else {
                return UITableViewAutomaticDimension
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return 25
            }
            return UITableViewAutomaticDimension
        }
        else if indexPath.section == 2 {
                return UITableViewAutomaticDimension
   
        }
        else {
            if indexPath.row == 0 {
                return 51
            }
            else {
            return 51
            }
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 2
        case 3:
            if data.join.count > 0 {
            return data.join.count+1
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return CGFloat.leastNonzeroMagnitude
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != 0 {
        return " "
        }
        return ""
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "joinCell", for: indexPath) as! JoinViewTableViewCell
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            if cell.join.allTargets.first == nil {
                if created {
                    cell.join.addTarget(self, action:  #selector(ViewActivityTableViewController.removeActivity), for: .touchUpInside)
                    cell.join.backgroundColor = UIColor.red
                    cell.join.setAttributedTitle(NSAttributedString(string: "Delete", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!]), for: .normal)
                }
                else {
                cell.join.addTarget(self, action: #selector(ViewActivityTableViewController.clickJoin(sender:)), for: .touchUpInside)
                for user in data.join {
                    if user.username == currentUser.username {
                        cell.join.tag = 1
                        cell.join.backgroundColor = UIColor.stellaPurple()
                        cell.join.setAttributedTitle(NSAttributedString(string: "Joined", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!]), for: .normal)

                    }
                }
            }
            }
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            cell.textLabel?.text = data.title
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
            cell.textLabel?.textColor = UIColor.black
            return cell
            
        }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
                cell.textLabel?.text = "Description"
                 cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
                cell.textLabel?.textColor = UIColor.black
                return cell
            }
            else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            cell.textLabel?.text = data.description
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            return cell
            }
        }
        else if indexPath.section == 2 {
          if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            cell.textLabel?.text = "⏱ \(data.startdateText) - \(data.enddateText)"
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            return cell
             }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            cell.textLabel?.text = data.locationAddress
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            
            return cell
          }
        }
        else {
    
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
                cell.textLabel?.text = "Going with"
                cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 19.0)
                return cell
            }
            else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "joinUserCell", for: indexPath) as! JoinUserTableViewCell
            print("indexpath for activigy cell bitch \(indexPath.row)")
            cell.name.text = data.join[indexPath.row-1].username
            if let img = FriendListViewController.imageCache.object(forKey: data.join[indexPath.row-1].id as NSString) {
                cell.configureCell(user:  data.join[indexPath.row-1],img: img)
            } else {
                cell.configureCell(user:  data.join[indexPath.row-1])
            }
            return cell
            }
        }
        return UITableViewCell()
      }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 2 && indexPath.row == 1 {
            self.toMap()
        }
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


