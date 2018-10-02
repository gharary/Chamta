//
//  ShoppingTableVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/24/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class ShoppingTableVC: UITableViewController {

    let defaults = UserDefaults.standard
    let cellIdentifier = "shoppingItemCell"
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var basketSum: UILabel!
    
    
    var receivedData = Data()
    var shoppingList: [shoppingItems] = []
    var globalSum: Float = 0.0
    var profile : Profile? = nil
    var tableData: [AnyObject]!
    var selectedPrdID: String = ""
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearListBtn(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "اخطار!", message: "آیا مطمئن هستید میخواهید لیست خرید را حذف کنید؟", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "بلی، پاک شود!", style: .destructive, handler: { (action) in
            //print("data should Delete!")
            self.globalSum = 0
            self.basketSum.text = ""
            self.shoppingList.removeAll()
            self.tblView.reloadData()
            self.defaults.removeObject(forKey: "shoppingList")
            self.defaults.synchronize()
            self.tblView.reloadData()
            //self.performSegueToReturnBack()
            self.dismiss(animated: true, completion: nil)
            
            
        }))
        alert.addAction(UIAlertAction(title: "نه!", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
        }
        let login:Bool = defaults.bool(forKey: "loggedIn")
        if !login {
            let storyboard = UIStoryboard(name: "Register", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginSignupVC")
            self.present(initialViewController, animated: true, completion: nil)
        } else {
            
            self.tableData = []
            getUserOff()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
        }
        guard let login:Bool = defaults.bool(forKey: "loggedIn") else {
            return
        }
        if !login  {
            let storyboard = UIStoryboard(name: "Register", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginSignupVC")
            self.present(initialViewController, animated: true, completion: nil)
        } else {
            
            self.tableData = []
            getUserOff()
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPrdID = shoppingList[indexPath.row].id!
        
        performSegue(withIdentifier: "showProductDetail", sender: nil)
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let result = UIView()
        
        // recreate insets from existing ones in the table view
        let insets = tableView.separatorInset
        let width = tableView.bounds.width - insets.left - insets.right
        let sepFrame = CGRect(x: insets.left, y: -0.5, width: width, height: 0.5)
        
        //create layer with separator, setting color
        let sep = CALayer()
        sep.frame = sepFrame
        sep.backgroundColor = tableView.separatorColor?.cgColor
        result.layer.addSublayer(sep)
        
        return result
        
        
    }
    @IBAction func shopCompletionBtn(_ sender: UIButton)  {
       
        if shoppingList.count > 0 {
            performSegue(withIdentifier: "showBasketCompletion", sender: nil)
        
            } else {
                let alert = UIAlertController(title: "خطا!", message: "سبد خرید خالی است!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                    self.performSegueToReturnBack()
            }))
            
            }
        
    }
    
    
    func getUserOff()  {
        SVProgressHUD.show()
        let mobile = defaults.object(forKey: "userMobile") as? String
        //print(mobile!)
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"profile", "phone":mobile!]
        
        //DispatchQueue.main.async {
          
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            self.receivedData = response.data!
            /* print(response.data!)
            print(response.result.value!)
            print(response.result.debugDescription)
            */
            //self.parseProfileJSON()
            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                SVProgressHUD.showError(withStatus: "Server Error")
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                print("error parsing data. no data")
                SVProgressHUD.showError(withStatus: "Data Error")
                return
            }
            SVProgressHUD.showSuccess(withStatus: "Data Loaded!")
            SVProgressHUD.dismiss(withDelay: 1.0)
            for data in tempData {
                self.tableData.append(data)
            }
            
            let tblData = self.tableData[0] as! [String:AnyObject]
            
            self.profile = Profile(id: tblData["id"] as? String, name: tblData["name"] as? String, phone: tblData["phone"] as? String, home_phone: tblData["home_phone"] as? String, address: tblData["address"] as? String, email: tblData["email"] as? String, sms_code: tblData["sms_code"] as? String, off: tblData["off"] as? String, username: tblData["username"] as? String, date: tblData["date"] as? String, num_buy: tblData["num_buy"] as? String, buys: tblData["buys"] as? String, birth: tblData["birth"] as? String)

        }
        
        
    }
    

    
    @objc func buttonAction(_ sender: UIButton!) {
        print("Button tapped")
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tblView.beginUpdates()
            
            self.shoppingList.remove(at: indexPath.row)
            defaults.set(try? PropertyListEncoder().encode(shoppingList), forKey: "shoppingList")
            
            tblView.deleteRows(at: [indexPath], with: .automatic)
            
            tblView.endUpdates()
            
        }
        globalSum = 0
        if shoppingList.count == 0 { basketSum.text = " ۰ تومان" }
        tblView.reloadData()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ShoppingCell

        //Fetch Item
        let item = shoppingList[indexPath.row]
        
        // Configure the cell...
        cell?.productName.text = item.name
        let num:Float = item.num!
        //print(item.price!)
        let price: Float = item.price!
        let sum: Float = num * price
        
        cell?.productPrice.text = String(sum)
        if let imageData = defaults.object(forKey: item.id!), let image = UIImage(data: imageData as! Data) {
            cell?.productImage.image = image
            
        }
        
        //self.globalSum +=  sum
        self.globalSum += sum
        basketSum.text = String(Int(globalSum)) + "   هزارتومان   "
        return cell!
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBasketCompletion" {
            let dc = segue.destination as? shopCompletionVC
            dc?.profile = self.profile
            
            dc?.globalSum = Float(self.globalSum)
        }
        else if segue.identifier == "showProductDetail" {
            
            
            if let nav = segue.destination as? UINavigationController, let dc = nav.topViewController as? ProductDetail {
                let indexPath = self.tableView.indexPathForSelectedRow
                dc.id = shoppingList[(indexPath?.row)!].id
                dc.amount = shoppingList[(indexPath?.row)!].num!
                //dc.id = selectedPrdID
                dc.segueString = "segueFromShoppingList"
                
            }
        }
    }

}
