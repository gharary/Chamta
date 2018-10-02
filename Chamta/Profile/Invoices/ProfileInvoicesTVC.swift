//
//  ProfileInvoicesTVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/11/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "ProfileInvoiceCell"


class ProfileInvoicesTVC: UITableViewController {

    
    @IBOutlet var tblDemo: UITableView!
    var mobilePhone: String = ""
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    
    var defaults = UserDefaults.standard
    var tableData: [AnyObject]!
    {
        //A property Observer to refresh data in table any time this array changes
        didSet {
            tblDemo?.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        callServer()
        callServerForUsername()

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableData = []
        
    }

    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        performSegueToReturnBack()
        //self.dismiss(animated: true, completion: nil)
    }
    func callServerForUsername() {
        if mobilePhone == "" {
            mobilePhone = defaults.value(forKey: "userMobile") as! String
        }
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
        }
    }
    
    func callServer() {
        
        var usernameStr: String = ""
        if  let username = defaults.object(forKey: "username") {
            usernameStr = username as! String
            
        } 
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"factor", "username":usernameStr]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                let alert = UIAlertController(title: "خطا", message: "اتصال به اینترنت برقرار نشد. مجدد امتحان کنید", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                    self.performSegueToReturnBack()
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
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.tableData = []
            for data in tempData {
                
                self.tableData.append(data)
            }
            //self.configDate()
        }
            
        
    }

    func configDate() {
        for var item in tableData {
            
            if var dateUnix = item["date"] as? String {
                let subStrDate = dateUnix.prefix(16)
                let subStr = String(subStrDate)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
                dateFormatter.calendar = Calendar(identifier: .gregorian)
                let dateInGrogrian = dateFormatter.date(from: subStr)
                
                let calender = NSCalendar(calendarIdentifier: NSCalendar.Identifier.persian)
                let components = calender?.components(NSCalendar.Unit(rawValue: UInt.max), from: dateInGrogrian!)
                
                let year =  components!.year
                let month = components!.month
                let day = components!.day
                let hour = components?.hour
                let minute = components?.minute
                dateFormatter.calendar = Calendar(identifier: .persian)
                dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
                //dateFormatter.locale =  NSLocale(localeIdentifier: "fa_IR") as Locale!
                //let datePersian = dateFormatter.date(from: subStr)
                let datePersian = "\(String(describing: year!))/\(String(describing: month!))/\(String(describing: day!)) \(String(describing: hour!)):\(String(describing: minute!))"
                print(datePersian)
                //item["date"] = datePersian
                
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProfileInvoiceCell

        var dictionary: [String:AnyObject] = [:]
        
        dictionary = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        if let dateUnix = dictionary["date"] as? String {
            let subStrDate = dateUnix.prefix(16)
            let subStr = String(subStrDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            let dateInGrogrian = dateFormatter.date(from: subStr)
            
            let calender = NSCalendar(calendarIdentifier: NSCalendar.Identifier.persian)
            let components = calender?.components(NSCalendar.Unit(rawValue: UInt.max), from: dateInGrogrian!)
            
            let year =  components!.year
            let month = components!.month
            let day = components!.day
            let hour = components?.hour
            let minute = components?.minute
            dateFormatter.calendar = Calendar(identifier: .persian)
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
            //dateFormatter.locale =  NSLocale(localeIdentifier: "fa_IR") as Locale!
            //let datePersian = dateFormatter.date(from: subStr)
            let datePersian = "\(String(describing: year!))/\(String(describing: month!))/\(String(describing: day!)) \(String(describing: hour!)):\(String(describing: minute!))"
            cell.dateLbl.text = String(describing: datePersian)
            //print(datePersian)
            
        }
        
        
        // Configure the cell...

        cell.codeLbl.text = dictionary["code"] as? String
        cell.priceLbl.text = dictionary["all_cost"] as? String
        //cell.dateLbl.text = dictionary["date"] as? String
        if dictionary["status"] as? String == "0" {
            cell.statusImg.image = UIImage(named: "tick")
        } else {
            cell.statusImg.image = nil
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInvoiceDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow
            if let dc = segue.destination as? InvoiceDetailTableVC {
            var dictionary: [String:Any] = tableData[(indexPath! as NSIndexPath).row] as! [String:AnyObject]
            dc.invoiceID = (dictionary["code"] as? String)!
            }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
