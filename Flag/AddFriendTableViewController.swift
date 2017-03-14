//
//  AddFriendTableViewController.swift
//  Flag
//
//  Created by marky RE on 11/30/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class AddFriendTableViewController: UITableViewController {
    var stringArr:[String] = [" Friend Request"," Add by Username"," Add from Contacts"," Add from Facebook"," Share Username"]
    var imageArr:[UIImage] = [UIImage(named:"request")!,UIImage(named:"Search")!,UIImage(named:"AddressBook")!,UIImage(named:"Facebook")!,UIImage(named:"InviteFilled")!]
    var menu:[NSMutableAttributedString] = []
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Add Friends"
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.navigationController?.navigationBar.tintColor = UIColor.stellaPurple()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
       
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)!]
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        for i in 0..<stringArr.count {
            let attachment = NSTextAttachment()
            attachment.image = imageArr[i]
            attachment.bounds = CGRect(x:0,y: -10.0, width:attachment.image!.size.width, height:attachment.image!.size.height)
            let attachmentString = NSAttributedString(attachment: attachment)
            let str:NSMutableAttributedString = NSMutableAttributedString(string:"")
            let arrString = NSMutableAttributedString(string:" "+stringArr[i])
            str.append(attachmentString)
            str.append(arrString)
            menu.append(str)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menu.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath)
        cell.textLabel?.attributedText = menu[indexPath.row]
        if indexPath.row != 4 {
            cell.accessoryType = .disclosureIndicator
        }
        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.row {
        case 0:
            let view = self.storyboard?.instantiateViewController(withIdentifier: "friendRequest") as! FriendRequestViewController!
            self.navigationController?.pushViewController(view!, animated: true)
        break
        case 1:
            let view = self.storyboard?.instantiateViewController(withIdentifier: "addUsername") as! SearchUsernameTableViewController!
            self.navigationController?.pushViewController(view!, animated: true)
        break
        case 2:
            let view = self.storyboard?.instantiateViewController(withIdentifier: "addContact") as! SearchContactTableViewController!
            self.navigationController?.pushViewController(view!, animated: true)
            break
        case 3:
            let view = self.storyboard?.instantiateViewController(withIdentifier: "addFacebook") as! SearchFacebookTableViewController!
            self.navigationController?.pushViewController(view!, animated: true)
            break
        case 4:
            shareUsername(username:currentUser.username)
            break
        default:
            break
        }
    }
    
    func shareUsername(username:String) {
        let activityViewController = UIActivityViewController(activityItems: [username as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
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
