//
//  ChangePasswordTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/10/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
class ChangePasswordTableViewController: UITableViewController,UITextFieldDelegate {
    var email = UITextField()
    var password = UITextField()
    var confirm = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        
        self.navigationItem.title = "Change Your Email"
        self.navigationController?.navigationBar.titleTextAttributes =  [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        let leftButton = UIBarButtonItem(image: UIImage(named:"Delete"), style: .plain, target: self, action: #selector(ChangePasswordTableViewController.closeView))
        let rightButton = UIBarButtonItem( barButtonSystemItem: .done, target: self, action: #selector(ChangePasswordTableViewController.updateDone))
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationController?.navigationBar.tintColor = UIColor.stellaPurple()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    func updateDone() {
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.activityIndicatorViewStyle = .white
        activity.center = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
        activity.layer.cornerRadius = 5.0
        activity.backgroundColor = UIColor.darkGray
        self.view.addSubview(activity)
        activity.startAnimating()
        FIRAuth.auth()?.signIn(withEmail: (FIRAuth.auth()!.currentUser?.email!)!, password:self.password.text!, completion: {(user, error) in
            if error == nil {
                FIRAuth.auth()?.currentUser?.updateEmail(self.email.text!, completion: { error in
                    if error == nil {
                        activity.stopAnimating()
                        currentUser.email = FIRAuth.auth()!.currentUser!.email!
                        let alert = UIAlertController(title: "Update Complete", message: "Update Email Complete", preferredStyle:.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        activity.stopAnimating()
                        activity.removeFromSuperview()
                        let alert = UIAlertController(title: "Error", message: "Update Email Error", preferredStyle:.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion:{_ in self.closeView()})
                    }

                })
            }
            else {
                activity.stopAnimating()
                activity.removeFromSuperview()
                let alert = UIAlertController(title: "Error", message: "email or password is incorrect, please try again", preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: - Table view data source
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            self.confirm.becomeFirstResponder()
        }
        else {
            
        }
        return true
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "changepassword", for: indexPath)
                if cell.subviews.count == 2 {
                    if indexPath.row == 0 {
                        self.email = UITextField(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width-10, height: 51))
                        self.email.tag = 0
                        
                        let placeholder = NSAttributedString(string: "New Email Address", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!])
                        self.email.attributedPlaceholder = placeholder;
                       email.delegate = self
                        email.returnKeyType = .next
                        email.isSecureTextEntry = true
                        email.clearButtonMode = .whileEditing
                        email.font = UIFont(name: "HelveticaNeue-Bold", size: 22.0)!
                        cell.addSubview(self.email)
                    }
        else if indexPath.row == 1 {
            self.password = UITextField(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width-10, height: 51))
            self.password.tag = 1
            
            let placeholder = NSAttributedString(string: "Password", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!])
            self.password.attributedPlaceholder = placeholder;
            password.delegate = self
            password.returnKeyType = .next
            password.isSecureTextEntry = true
            password.clearButtonMode = .whileEditing
            password.font = UIFont(name: "HelveticaNeue-Bold", size: 22.0)!
            cell.addSubview(self.password)
        }
        else {
            self.confirm = UITextField(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width-10, height: 51))
            self.confirm.tag = 2
            let placeholder = NSAttributedString(string: "re-confirm password", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 19.0)!])
            self.confirm.attributedPlaceholder = placeholder;
            confirm.delegate = self
            confirm.returnKeyType = .done
            confirm.isSecureTextEntry = true
            confirm.clearButtonMode = .whileEditing
            confirm.font = UIFont(name: "HelveticaNeue-Bold", size: 22.0)!
            cell.addSubview(self.confirm)
         }
        }
        return cell
                    
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
