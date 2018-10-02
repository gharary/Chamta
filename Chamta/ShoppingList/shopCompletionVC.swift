//
//  shopCompletionVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/9/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import SVProgressHUD

class shopCompletionVC: UIViewController, UIScrollViewDelegate {

    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fastDeliveryBtn: UIButton!
    @IBOutlet weak var fastDeliveryUIView: UIView!
    @IBOutlet weak var simpleDeliveryUIView: UIView!
    @IBOutlet weak var simpleDeliveryBtn: UIButton!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var addressSwitchButton: UISwitch!
    @IBOutlet weak var newAddressTF: UITextField!
    @IBOutlet weak var newAddressLbl: UILabel!
    @IBOutlet weak var descriptionUIView: UIView!
    @IBOutlet weak var addressUIView: UIView!
    @IBOutlet weak var priceUIView: UIView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var offSaveLbl: UILabel!
    @IBOutlet weak var useOffSave: UISwitch!
    @IBOutlet weak var finalPrice: UILabel!
    
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    
    
    var shoppingList: [shoppingItems] = []
    var receivedData = Data()
    var defaults = UserDefaults.standard
    var globalSum: Float = 0.0
    var sendType: Bool = false  //false means Simple, True means Express
    var profile : Profile? = nil
    var jsonData: Data = Data()
    var jsonString: String = ""
    var sendCost:String = ""    //هزینه ارسال فوری
    var minBuy: String = ""     //حداقل خرید برای استفاده از تخفیفی
    var sendCostBool: Bool = false
    var tableData: [AnyObject]!
    var mobilePhone: String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        getSettingsData()
        getInvoiceCalculation()
        getUserOff()
        callServerForUsername()
        //invoiceCal()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getSettingsData()
        priceLbl.text = String(globalSum)
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
        }
        offSaveLbl.text = "0"
        setupFields()
       
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
    
    
    func getUserOff() {
        let mobile = defaults.object(forKey: "userMobile") as? String
        //if profile?.phone == nil { profile?.phone = mobile }
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"profile", "phone":mobile!]
        
        
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            guard let jsonResult = response.result.value as? [String: Any] else {
                print("Didn't get data as JSON from API")
                print("Error: \(String(describing: response.result.error))")
                return
            }
            print(jsonResult)
            
            self.receivedData = response.data!
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                print("error parsing data. no data")
                return
            }
            
            for data in tempData {
                self.tableData.append(data)
            }
            
            let tblData = self.tableData[0] as! [String:AnyObject]
            
            self.profile = Profile(id: tblData["id"] as? String, name: tblData["name"] as? String, phone: tblData["phone"] as? String, home_phone: tblData["home_phone"] as? String, address: tblData["address"] as? String, email: tblData["email"] as? String, sms_code: tblData["sms_code"] as? String, off: tblData["off"] as? String, username: tblData["username"] as? String, date: tblData["date"] as? String, num_buy: tblData["num_buy"] as? String, buys: tblData["buys"] as? String, birth: tblData["birth"] as? String )
            self.defaults.set(self.profile?.username, forKey: "username")
            //self.parseProfileJSON()
        }
        
        
    }

    func getInvoiceCalculation() {
        
        let sendtype = (sendType ? "فوری" : "معمولی")
        let send_type = String(utf8String: sendtype.cString(using: .utf8)!)
        let address = (addressSwitchButton.isOn ? "" : newAddressTF.text)
        let useOff = (useOffSave.isOn ? true : false )
        let phone = profile?.phone!
        let title = descriptionTF.text!
        do {
            let jsonEncoder = JSONEncoder()
            jsonData = try jsonEncoder.encode(shoppingList)
            jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        //print(jsonString)
        //let json = String(utf8String: jsonString.cString(using: .utf8)!)
        let parameters: Parameters = ["action":"calculation", "produce":jsonString, "address":address!, "send_type":send_type!, "use_off":useOff, "phone":phone!, "title":title]
        print(String(describing: parameters))
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        
        Alamofire.request( baseUrl!, method: .post , parameters: parameters, headers: headers)
            
            
            .responseJSON { response in
                switch response.result {
                case .success:
                        print(response.result.value!)
                case .failure:
                    print(response.result.error!)
                }
            }
            .responseString { response in
                
                switch response.result {
                case .success:
                    let str:String = response.result.value!
                    let muSub = str.split(separator: "{")
                    //print(muSub[0])
                    //print(muSub[1])
                    let myStr = "{" + muSub[0]
                    if let data = myStr.data(using: .utf8) {
                        do {
                            let dict =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            print(dict!["msg"]!)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                case .failure:
                    print(response.result.error!)
                }
        }
    }

    
    @IBAction func submitOrder(_ sender: UIButton) {
        
        do {
            let jsonEncoder = JSONEncoder()
            jsonData = try jsonEncoder.encode(shoppingList)
            jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        callServer(action: "buy")
        //testSubmitClick()
        
    }
    
    func testSubmitClick() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            if let viewControllers = window.rootViewController?.childViewControllers {
                for viewController in viewControllers {
                    print(viewController.debugDescription)
                    UIView.animate(withDuration: 1.0, animations: {
                        print(viewController)
                        viewController.dismiss(animated: true, completion: nil)
                    })
                    
                }
            }
        }
    }
    func callServer(action: String) {
        
        let sendtype = (sendType ? "فوری" : "معمولی")
        let username = defaults.object(forKey: "username")
        //print(username!)
        let usernameStr:String = username as! String
        let address = (addressSwitchButton.isOn ? "" : newAddressTF.text)
        let useOff = (useOffSave.isOn ? true : false )
        let phone = profile?.phone!
            
        let title = descriptionTF.text!
        //print(jsonString)
        
        let parameters: Parameters = ["action":action, "produce":jsonString, "username":usernameStr, "address":address!, "send_type":sendtype, "use_off":useOff, "phone":phone!, "title":title]
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        
        Alamofire.request( baseUrl!, method: .post , parameters: parameters, headers: headers)
            
            
            .responseJSON { response in
           
            guard response.result.error == nil else {
                print("Send Basket error on connecting to URL!")
                print(response.result.error!)
                
                return
            }
            if (response.result.value as? [[String:Any]]) != nil {
                
                let msg: [String:Any] = response.result.value as! [String:Any]
                let alert = UIAlertController(title: "خطا", message: msg["msg"] as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                    self.performSegueToReturnBack()
                }))
                self.present(alert, animated: true, completion: nil)
            } else
                if (response.result.value as? [String:Any]) != nil {
                
                let msg: [String:Any] = response.result.value as! [String:Any]
                let alert = UIAlertController(title: "خطا", message: msg["msg"] as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                    self.performSegueToReturnBack()
                }))
                self.present(alert, animated: true, completion: nil)
                
                }
        }
            .responseString { response in
                guard response.result.error == nil else {
                    print("Send Basket error on connecting to URL!")
                    print(response.result.error!)
                    
                    return
                }
                
                //print("Server Response: \(String(describing: response.result.value))")
                let str :String = response.result.value!
                //print("Character Count: \(str.count)")
                if str.range(of: "EC") != nil {
                    
                    let mySub = str.split(separator: "{")
                    if mySub.count > 2 {
                        
                        let myStr = "{" + mySub[1]
                        if let data = myStr.data(using: .utf8) {
                            do {
                                let dict =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                print(dict!["msg"]!)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    
                } else
                if str.count > 20 {
                    let mySub = str.suffix(15)
                    let mySubString = mySub.prefix(14)
                    print(mySubString)
                    let alert = UIAlertController(title: "تبریک!", message: "فاکتور شما با کد رهگیری \(mySubString) ثبت شد و به زودی برای شما ارسال خواهد شد.", preferredStyle: .alert)
                
                    alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "mainTabbarVC")
                        self.present(initialViewController, animated: true, completion: nil)
 
                        //
                        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                            if let viewControllers = window.rootViewController?.childViewControllers {
                                for viewController in viewControllers {
                                    print(viewController.debugDescription)
                                    UIView.animate(withDuration: 1.0, animations: {
                                        print(viewController)
                                        viewController.dismiss(animated: true, completion: nil)
                                    })
                                    
                                }
                            }
                        }*/
                    }))
                    self.resetDefaults()
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "تبریک!", message: "فاکتور شما با کد رهگیری \(str) ثبت شد و به زودی برای شما ارسال خواهد شد.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "mainTabbarVC")
                        self.present(initialViewController, animated: true, completion: nil)
                        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                            if let viewControllers = window.rootViewController?.childViewControllers {
                                for viewController in viewControllers {
                                    print(viewController.debugDescription)
                                    UIView.animate(withDuration: 1.0, animations: {
                                        print(viewController)
                                        viewController.dismiss(animated: true, completion: nil)
                                    })
                                    
                                }
                            }
                        }*/
                    }))
                    self.resetDefaults()
            
                    self.present(alert, animated: true, completion: nil)
                }
            }
        
    }

    func getSettingsData() {
        SVProgressHUD.show()
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"aboutus"]
        
        
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                SVProgressHUD.showError(withStatus: "Server Error Loading Shop Data")
                return
            }
            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                SVProgressHUD.showError(withStatus: "Shop Data Error")
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                print("error parsing data. no data")
                SVProgressHUD.showError(withStatus: "Shop Data Error!")
                return
            }
            
            self.sendCost = tempData[0]["send_cost"] as! String
            self.minBuy = tempData[0]["min_buy"] as! String
            
            SVProgressHUD.dismiss(withDelay: 3)
            
        }
    }
    
    func setupFields() {
        
        simpleDeliveryUIView.alpha = 1
        fastDeliveryUIView.alpha = 0.5
        
        offSaveLbl.text = profile?.off
        
        finalPrice.text = String(globalSum) + "   هزارتومان   "
        
        
        fastDeliveryUIView.layer.cornerRadius = 5
        fastDeliveryUIView.layer.borderWidth = 4
        fastDeliveryUIView.layer.borderColor = UIColor.gray.cgColor
        
        simpleDeliveryUIView.layer.cornerRadius = 5
        simpleDeliveryUIView.layer.borderWidth = 4
        simpleDeliveryUIView.layer.borderColor = UIColor.gray.cgColor
        
        newAddressLbl.alpha = 0.5
        newAddressTF.alpha = 0.5
        newAddressTF.isEnabled = false
        
        descriptionUIView.layer.cornerRadius = 5
        descriptionUIView.layer.borderWidth = 4
        descriptionUIView.layer.borderColor = UIColor.gray.cgColor
        
        addressUIView.layer.cornerRadius = 5
        addressUIView.layer.borderWidth = 4
        addressUIView.layer.borderColor = UIColor.gray.cgColor
        
        priceUIView.layer.cornerRadius = 5
        priceUIView.layer.borderWidth = 4
        priceUIView.layer.borderColor = UIColor.gray.cgColor
    }
    @IBAction func fastDeliveryButton(_ sender: UIButton) {
        simpleDeliveryUIView.alpha = 0.5
        fastDeliveryUIView.alpha = 1
        sendType = true
        if !sendCostBool {
            if !minBuy.isEmpty, globalSum < Float(minBuy)! {
                globalSum += Float(sendCost)!
                finalPrice.text = String(globalSum) + "   هزارتومان   "
                sendCostBool = !sendCostBool
            }
        }
    }
    
    @IBAction func simpleDeliveryButton(_ sender: UIButton) {
        simpleDeliveryUIView.alpha = 1
        fastDeliveryUIView.alpha = 0.5
        sendType = false
        if sendCostBool {
            globalSum -= Float(sendCost)!
            finalPrice.text = String(globalSum) + "   هزارتومان   "
            sendCostBool = !sendCostBool
        }
    }
    
    @IBAction func useOffSwitch(_ sender: UISwitch) {

            if globalSum > 20000 {
                if sender.isOn {
                    globalSum -= Float((profile?.off)!)!
                    finalPrice.text = String(globalSum) + "   هزارتومان   "
            
                } else {
                    globalSum += Float((profile?.off)!)!
                    finalPrice.text = String(globalSum) + "   هزارتومان   "
                }
            
            } else {
                let alert = UIAlertController(title: "خطا!", message: "حداقل فاکتور برای استفاده از تخفیفی باید بیشتر از ۲۰،۰۰۰ توان باشد", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    
        
    }
    
    @IBAction func addressSwitchBtn(_ sender: UISwitch) {
    
        if sender.isOn {
            newAddressLbl.alpha = 0.5
            newAddressTF.alpha = 0.5
            newAddressTF.isEnabled = false
            
        } else {
            newAddressLbl.alpha = 1
            newAddressTF.alpha = 1
            newAddressTF.isEnabled = true
            newAddressTF.becomeFirstResponder()
        }
        
    }
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: "shoppingList")
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
