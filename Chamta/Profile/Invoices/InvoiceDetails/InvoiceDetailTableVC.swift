//
//  InvoiceDetailTableVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/14/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "InvoiceDetailCell"


class InvoiceDetailTableVC: UITableViewController {

    @IBOutlet var tblDemo: UITableView!
    
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    var invoiceID: String = ""
    var tableData: [AnyObject]!
    {
        //A property Observer to refresh data in table any time this array changes
        didSet {
            tblDemo?.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        callServer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableData = []
        
        
    }

    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        //self.dismiss(animated: true, completion: nil)
        performSegueToReturnBack()
    }
    func callServer() {
        
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"factor", "code":invoiceID]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            
            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                let msg : [String:Any] = response.result.value as! [String : Any]
                let alert = UIAlertController(title: "خطا", message: msg["msg"] as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                    //self.dismiss(animated: true, completion: nil)
                    self.performSegueToReturnBack()
                    
                }))
                self.present(alert
                    , animated: true, completion: nil)
                return
                
            }
            
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                print("error parsing data. no data")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InvoiceDetailCell

        var dictionary: [String:AnyObject] = [:]
        dictionary = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        // Configure the cell...

        cell.productName.text = dictionary["name"] as? String
        cell.productPrice.text = dictionary["cost"] as? String
        cell.productAmount.text = dictionary["num"] as? String
        
        return cell
    }
}
extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
