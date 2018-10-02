//
//  SubscriptionsTableVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/13/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "SubscriptCell"

class SubscriptionsTableVC: UITableViewController {

    @IBOutlet weak var tblDemo : UITableView!
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    let defaults: UserDefaults = UserDefaults.standard
    
    var mobilePhone: String = ""
    var invoiceID: String = ""
    var tableData:[AnyObject]!
    {
        didSet{
            self.tblDemo?.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableData = []
        if mobilePhone == "" {
            mobilePhone = defaults.value(forKey: "userMobile") as! String
        }
        callServerForUsername()
    }

    func callServerForUsername() {
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"profile", "phone":mobilePhone]
        
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            
            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                print("error parsing data. no data")
                return
            }
            
            let tblData = tempData[0] as! [String:AnyObject]
            self.defaults.set(tblData["username"], forKey: "username")
            self.callServer()
        }
    }
    
    func callServer() {
        let username = defaults.object(forKey: "username")
        //print(username!)
        let usernameStr:String = username as! String
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"peresent", "username":usernameStr]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                let alert = UIAlertController(title: "خطا", message: "اتصال به اینترنت برقرار نشد. مجدد امتحان کنید", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                let alert = UIAlertController(title: "خطا", message: "موردی یافت نشد!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                    self.performSegueToReturnBack()
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                print("error parsing data. no data")
                let alert = UIAlertController(title: "خطا", message: "موردی یافت نشد!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                    self.performSegueToReturnBack()
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            for data in tempData {
                self.tableData.append(data)
            }
        }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier , for: indexPath) as! SubscriptionCell
        var dictionary: [String:AnyObject] = [:]
        
        dictionary = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        

        // Configure the cell...
        
        cell.subscriptName.text = dictionary[""] as? String
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
