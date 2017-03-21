//
//  CountryCodeTableViewController.swift
//  Flag
//
//  Created by marky RE on 12/11/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit

class CountryCodeTableViewController: UITableViewController {
    let arr = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","Y","Z"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.sectionIndexColor = UIColor.stellaPurple()
        let close = UIBarButtonItem(image: UIImage(named: "Delete"), style: .plain, target: self, action: #selector(CountryCodeTableViewController.closeView))
        close.tintColor = UIColor.stellaPurple()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),for:.default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Choose Your Country"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 22.0)!]
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = close
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Countries.countries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Countries.countries[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(section)
        return arr[section]
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView(section: section)
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return arr
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countrycode", for: indexPath)
        cell.textLabel?.text = Countries.countries[indexPath.section][indexPath.row].name
            let label = UILabel()
            label.text = Countries.countries[indexPath.section][indexPath.row].phoneExtension
            label.textColor = UIColor.lightGray
            label.font = UIFont(name: "HelveticaNeue", size: 17.0)!
            label.sizeToFit()
            cell.accessoryView = label
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        print("accs view \(cell?.accessoryView)")
        let label = cell?.accessoryView as! UILabel
        let data = ["phoneextension":label.text!,"region":Countries.countries[indexPath.section][indexPath.row].countryCode]
         self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePhoneExtension"), object: nil,userInfo:data)
       
    }
    
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    func headerView(section:Int) -> UIView {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        returnedView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x:10, y: 5, width: view.frame.size.width, height: 20))
        label.textColor = UIColor.stellaPurple()
        label.attributedText = NSAttributedString(string:arr[section], attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 17.0)!])
        returnedView.addSubview(label)
        
        return returnedView
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
