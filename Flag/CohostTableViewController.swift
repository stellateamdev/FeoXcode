//
//  CohostTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/14/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class CohostTableViewController: UITableViewController {
    var hostArray:[User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Who's Going.."
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]
        let leftButton = UIBarButtonItem(image: UIImage(named:"Delete")?.withRenderingMode(.alwaysTemplate), style: .plain, target:self, action: #selector(CohostTableViewController.closeView))
        let rightButton = UIBarButtonItem(title:"Done", style: .done, target:self, action: #selector(CohostTableViewController.setCohost))
        rightButton.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 17.0)!], for: .normal)
        rightButton.tintColor = UIColor.stellaPurple()
        rightButton.tag = 1
        leftButton.tintColor = UIColor.stellaPurple()
        leftButton.tag = 0
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cohostCell", for: indexPath) as! CohostTableViewCell
        print("cell counting \(userArray.count) \(indexPath.row)")
        cell.name.text = userArray[indexPath.row].username
        cell.profile.image = userArray[indexPath.row].profile
        cell.accessoryType = .none
        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! CohostTableViewCell
        print("jackass \(cell.accessoryType)")
        if cell.accessoryType == .none {
              cell.accessoryType = .checkmark
            hostArray.append(userArray[indexPath.row])
        }
        else {
            cell.accessoryType = .none
            hostArray.remove(at: indexPath.row)
            
        }
      
        
        cell.tintColor = UIColor.stellaPurple()
    }
    func closeView() {
        
        self.dismiss(animated: true, completion: nil)
    }
    func setCohost() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Cohost"), object: nil, userInfo: ["cohost":hostArray])
        self.dismiss(animated: true, completion: nil)
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
