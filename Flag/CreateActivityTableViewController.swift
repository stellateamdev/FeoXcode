//
//  CreateActivityTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/13/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import DatePickerDialog
import MapKit
import OneSignal
import Firebase
class CreateActivityTableViewController: UITableViewController {
    var startTime = DateTableViewCell()
    var endTime = DateTableViewCell()
    var disappearWithSegue = false
    var data = ActivityData()
    var locationRow = 1
    var finishChooseLocation = false
    var goingArray:[User] = []
    override func viewWillAppear(_ animated: Bool) {
        disappearWithSegue = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload again wtf \(data.id)")
        data.id = FIRAuth.auth()!.currentUser!.uid
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "Create Activity"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22)!]
        
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.init(white: 0.78, alpha: 0.3)
        self.tableView.backgroundColor = UIColor.RGB(r: 247, g: 247, b: 247)
        let leftButton = UIBarButtonItem(image: UIImage(named:"Delete")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(CreateActivityTableViewController.closeView))
        leftButton.tintColor = UIColor.stellaPurple()
        
        let rightButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(CreateActivityTableViewController.createActivity))
        rightButton.tintColor = UIColor.stellaPurple()
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton
        NotificationCenter.default.addObserver(self, selector: #selector(CreateActivityTableViewController.setlocation(_:)), name: NSNotification.Name(rawValue: "setLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateActivityTableViewController.setCohost(_:)), name:  NSNotification.Name(rawValue: "Cohost"), object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !disappearWithSegue {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    func showError() {
        let ac = UIAlertController(title: "Error", message: "please fill in all the details", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    func createActivity() {
        let row1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TitleTableViewCell
        print(row1)
        if row1.textField.text == "" {
            showError()
            return
        }
        else {
            data.title = row1.textField.text!
        }
        let row2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TextViewTableViewCell
        if row2.textView.text.isEmpty {
            showError()
            return
        }
        else {
        data.description = row2.textView.text!
        }
        data.pictureURL = currentUser.thumbnailURL
        if data.enddateText == "" || data.startdateText == "" || data.locationAddress == ""  {
            showError()
            return
        }
        let key = FIRDatabase.database().reference().child("Activities").childByAutoId().key
        FIRDatabase.database().reference().child("Activities/\(key)").updateChildValues(["key":"\(key)","uid":currentUser.id,"username":currentUser.username,"title":data.title
            , "description":data.description,"locationaddress":data.locationAddress,"latitude":"\(data.location.latitude)","longitude":"\(data.location.longitude)","pictureURL":data.pictureURL,"startdate":"\(data.startdate.timeIntervalSince1970)","enddate":"\(data.enddate.timeIntervalSince1970)","startdatetext":data.startdateText,"enddatetext":data.enddateText])
        for value in goingArray {
            FIRDatabase.database().reference().child("Activities/\(key)/Join").updateChildValues([value.id:value.id])
        }
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Friendlist").observeSingleEvent(of: .value, with: {(snap) in
            if snap.exists(){
                let friends = snap.value as! NSDictionary
                for friend in friends{
                    FIRDatabase.database().reference().child("Users/\(friend.value)/Activities").updateChildValues([key:key])
                }
            }
        })
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Activities").updateChildValues([key:key])
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Created").updateChildValues([key:key])
        FIRDatabase.database().reference().child("Activities/\(data.key)/Join").updateChildValues([currentUser.id:currentUser.id])
        print("check the damn datakey \(data.key) \(currentUser.id)")
        FIRDatabase.database().reference().child("Users/\(currentUser.id)/Joins").updateChildValues([key:key])
        for user in userArray {
            print("LOL \(user.oneid)")
             OneSignal.postNotification(["contents": ["en": "\(currentUser.username) created activity"], "include_player_ids": ["\(user.oneid)"]])
            FIRDatabase.database().reference().child("Users/\(user.id)/Notification").childByAutoId().updateChildValues([ "Activity" : key,"Time" :
                NSDate().timeIntervalSince1970,"thumbnailURL" : currentUser.thumbnailURL])
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadTableActivity")))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadTableCreated")))
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    func setlocation(_ noti:Notification) {
        finishChooseLocation = false
        data.locationAddress = noti.userInfo?["locationAddress"] as! String
        data.location = noti.userInfo?["location"] as! CLLocationCoordinate2D
        print("data.locationaddress \(data.locationAddress)")
      /*  if locationRow == 1 {
       self.tableView.beginUpdates()
    self.tableView.insertRows(at: [NSIndexPath(row: 1, section: 2) as IndexPath], with: .automatic)
                locationRow = 2
     self.tableView.endUpdates()
        }
        else {
            self.tableView.reloadData()
        }
        self.tableView.selectRow(at: NSIndexPath(row: 1, section: 2) as IndexPath, animated: false, scrollPosition: .none)
        self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: NSIndexPath(row: 1, section: 2) as IndexPath)
        finishChooseLocation = true */
        locationRow = 2
        self.tableView.reloadData()
        
        
    
    }
    func setCohost(_ noti:Notification) {
        data.join = noti.userInfo?["cohost"] as! [User]
        goingArray = data.join
        self.tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        disappearWithSegue = true
    }
}




extension CreateActivityTableViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 60
            }
            else {
                return UITableViewAutomaticDimension
            }
        }
        else if indexPath.section == 3 && indexPath.row > 0 {
            return 51
        }
        else {
            return 60
        }
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""

    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height:100))
        view.backgroundColor = UIColor.RGB(r: 247, g: 247, b: 247)
        return view
    } 
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height:100))
        view.backgroundColor = UIColor.RGB(r: 247, g: 247, b: 247)
        print("footerrrr")
        return view
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
            print("check locationrow \(locationRow)")
           return 1//locationRow
        case 3:
            print("data.join.count \(data.join.count)")
            return 1+data.join.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
          
            if indexPath.row == 0 {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleTableViewCell
                return cell
            }
            else {
               let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! TextViewTableViewCell
                cell.textView.delegate = self
                if cell.textView.text.isEmpty {
                    cell.textView.text = "Description"
                    cell.textView.textColor = UIColor.lightGray
                }
                return cell
            }
        }
            else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "date", for: indexPath) as! DateTableViewCell

                if indexPath.row == 0 {
                    print("checking things")
                    cell.title.text = "Start Time"
                    cell.title.textAlignment = .left
                   
                    cell.title.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
                    
                          cell.time.text = self.data.startdateText

                       // cell.accessoryType = .disclosureIndicator
                    
                    return cell
                }
                else {
                    cell.title.text = "End Time"
                   
                          cell.time.text = self.data.enddateText
                    // cell.accessoryType = .disclosureIndicator
             
                    cell.title.textAlignment = .left
                    
                    cell.title.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
                    return cell
                }
            }
        else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "date", for: indexPath) as! DateTableViewCell
                if locationRow == 2 {
                   cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0,0)
                    cell.indentationWidth = -1000
                    cell.indentationLevel = 1
                }
            cell.title.text = "Set Location"
            if data.locationAddress == "" {
                // cell.accessoryType = .disclosureIndicator
            }else{
                //cell.accessoryType = .none
            }
            cell.title.textAlignment = .left
            cell.time.text = data.locationAddress
            cell.title.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
                return cell
            

          /*  else {
                print("enter number 2")
                let cell = tableView.dequeueReusableCell(withIdentifier: "address", for: indexPath) as! LocationAddressTableViewCell
                cell.label.text = data.locationAddress
                cell.accessoryType = .none
                return cell
            } */
/*let cell = tableView.dequeueReusableCell(withIdentifier: "mapLocation", for: indexPath) as! MapTableViewCell
                let span = MKCoordinateSpanMake(0.01, 0.01)
                let region = MKCoordinateRegion(center: data.location, span: span)
                let annotation = MKPointAnnotation()
                annotation.coordinate = data.location
            
                cell.mapView.setRegion(region, animated: true)
                cell.mapView.removeAnnotations(cell.mapView.annotations)
                cell.mapView.addAnnotation(annotation)
                cell.label.text = data.locationAddress
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell
                
            } */
        }
        else if indexPath.section == 3 && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "createActivity", for: indexPath)
            cell.textLabel?.text = "Going with.."
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "joinUserCell", for: indexPath) as! GoingTableViewCell
            cell.name.text = data.join[indexPath.row-1].username
            
            cell.configureCell(user: data.join[indexPath.row-1],img:data.join[indexPath.row-1].profile)
            return cell
        }
        
        }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
              let cell = tableView.dequeueReusableCell(withIdentifier: "date", for: indexPath) as! DateTableViewCell
              cell.contentView.backgroundColor = UIColor.white
            if indexPath.row == 0 {
                cell.title.text = "Start Time"
                DatePickerDialog().show(title: "Start Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .dateAndTime) {
                    (date) -> Void in
                    if date == nil{
                        self.tableView.reloadData()
                        return
                    }
                    let format = DateFormatter()
                    format.dateFormat = "MMMM dd yyyy h:mm a"
                    cell.time.text = "\(format.string(from: date!))"
                    self.data.startdateText = cell.time.text!
                    self.data.startdate = date!
                    self.tableView.reloadData()
                }
            }
            else {
                cell.title.text = "End Time"
                DatePickerDialog().show(title: "End Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .dateAndTime) {
                    (date) -> Void in
                    if date == nil {
                        self.tableView.reloadData()
                        return
                    }
                    let format = DateFormatter()
                    format.dateFormat = "MMMM dd yyyy h:mm a"
                    cell.time.text = "\(format.string(from: date!))"
                    self.data.enddateText = cell.time.text!
                    self.data.enddate = date!
                    self.tableView.reloadData()
                    print("self.data.enddate \(self.data.enddateText) \(self.data.enddate)")
                }
            }
        }
        else if indexPath.section == 2 {
            self.tableView.deselectRow(at: indexPath, animated: false)
           
          /* if finishChooseLocation {
                locationRow = 1
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [NSIndexPath(row: 1, section: 2) as IndexPath ], with: .automatic)
                self.tableView.endUpdates()
            finishChooseLocation = false
                //self.tableView.reloadData()
            } */
            
            self.performSegue(withIdentifier: "findLocation", sender: self)
        }
        else {
             self.tableView.deselectRow(at: indexPath, animated: false)
            self.performSegue(withIdentifier: "toCohost", sender: self)
        }
    }

}


extension CreateActivityTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "\n Description"
            textView.textColor = UIColor.lightGray
        }
    }
}
