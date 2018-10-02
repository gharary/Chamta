//
//  RegisterPhoneVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/22/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

class RegisterPhoneVC: UIViewController {

    @IBOutlet weak var phoneNo:UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    var defaults = UserDefaults.standard
    var oldUser:Bool = false
    var receivedData = Data()
    var mobile: String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        self.phoneNo.text = ""
        self.submitBtn.alpha = 1
        self.submitBtn.isEnabled = true
        self.phoneNo.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNo.becomeFirstResponder()
        receivedData = Data()
        
        submitBtn.layer.cornerRadius = 5
        submitBtn.layer.borderWidth = 3
        submitBtn.layer.borderColor = submitBtn.backgroundColor?.cgColor

    }
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func submitPhoneNo(_ sender: UIButton) {
        if !(phoneNo.text?.isEmpty)! {
            if (phoneNo.text?.count)! > 10 {
                let alert = UIAlertController(title: "خطا", message: "شماره تلفن همراه خود را بدون صفر وارد کنید", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه", style: .default, handler: {(alert: UIAlertAction!) in
                    self.phoneNo.text = ""
                    self.submitBtn.alpha = 1
                    self.submitBtn.isEnabled = true
                    self.phoneNo.becomeFirstResponder()
                    
                }))
                self.present(alert, animated: true, completion: nil)
                return
            } else if (phoneNo.text?.count)! < 10 {
                let alert = UIAlertController(title: "خطا", message: "شماره تلفن همراه خود را کامل وارد کنید", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه", style: .default, handler: {(alert: UIAlertAction!) in
                    self.phoneNo.text = ""
                    self.submitBtn.alpha = 1
                    self.submitBtn.isEnabled = true
                    self.phoneNo.becomeFirstResponder()
                    
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            submitBtn.alpha = 0.5
            submitBtn.isEnabled = false
            callServer()
        } else {
            print("Mobile TextField is Empty!")
        }
    }
    

    func callServer() {

        mobile = "0" + phoneNo.text!
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"reg_phone", "phone":mobile]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                let alert = UIAlertController(title: "خطا", message: "اتصال به اینترنت خود را چک کنید", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه", style: .default, handler: {(alert: UIAlertAction!) in
                    self.phoneNo.text = ""
                    self.submitBtn.alpha = 1
                    self.submitBtn.isEnabled = true
                    self.phoneNo.becomeFirstResponder()
                    
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            //print(response.result.value)
            if response.result.value as? String == "old_user" {
                //self.oldUser = true
                self.defaults.set(true, forKey: "loggedIn")
                self.defaults.set(self.mobile, forKey: "userMobile")
                
                /*
                //Show main VC
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "mainTabbarVC")
                if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                    if let viewControllers = window.rootViewController?.childViewControllers {
                        for viewController in viewControllers {
                            print(viewController.debugDescription)
                            UIView.animate(withDuration: 1.0, animations: {
                                viewController.dismiss(animated: true, completion: nil)
                            })
                            
                        }
                    }
                }

                self.present(initialViewController, animated: true, completion: nil)
                */
                self.dismiss(animated: true, completion: nil)
            }
            //self.performSegue(withIdentifier: "checkCodeVC", sender: nil)
            self.performSegue(withIdentifier: "showCompletion", sender: nil)
            //performSegueToReturnBack()
        }
            
            
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkCodeVC" {
            if let dc = segue.destination as? CheckCodeVC {
                dc.phoneNo = mobile
                dc.oldUser = self.oldUser
            }
        } else if segue.identifier == "showCompletion" {
            let vc = segue.destination as! registerCompletionVC
            vc.mobilePhone = mobile
            
        }
    }
}
