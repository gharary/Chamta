//
//  CheckCodeVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/25/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

class CheckCodeVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var forthTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    var phoneNo: String = ""
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    var receivedData = Data()
    var receivedCode: String = ""
    var defaults = UserDefaults.standard
    var oldUser:Bool = false
    @IBAction func checkCodeBtn(_ sender: UIButton) {
        receivedCode = firstTextField.text! + secondTextField.text! + thirdTextField.text! + forthTextField.text!
        callServer()
        //self.performSegue(withIdentifier: "showCompleteRegister", sender: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        
        
        firstTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    func setupTextFields() {
        submitBtn.layer.cornerRadius = 5
        submitBtn.layer.borderWidth = 3
        submitBtn.layer.borderColor = submitBtn.backgroundColor?.cgColor
        
        firstTextField.text = ""
        firstTextField.delegate = self
        firstTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        secondTextField.text = ""
        secondTextField.delegate = self
        secondTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        thirdTextField.text = ""
        thirdTextField.delegate = self
        thirdTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        forthTextField.text = ""
        forthTextField.delegate = self
        forthTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    
    }
    @objc func textFieldDidChange(textField: UITextField) {
        let text = textField.text
        if text?.utf16.count == 1 {
            switch textField {
            case firstTextField:
                secondTextField.becomeFirstResponder()
            case secondTextField:
                thirdTextField.becomeFirstResponder()
            case thirdTextField:
                forthTextField.becomeFirstResponder()
            default:
                break
            }
        } else {
            
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
   
    
    
    func callServer() {
        if (phoneNo != "")  && (receivedCode != "" ) {
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"check_code", "phone":phoneNo,"code":receivedCode]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            self.receivedData = response.data!
            //print(self.receivedData)
            //print(response.data!)
            //print(response.result.value!)
            
            guard let json = response.result.value as? String else {
                if let dict = response.result.value as? [String: Any] {
                    debugPrint(dict)
                    
                    let msg = dict["msg"]
                    //debugPrint(msg)
                    let alert = UIAlertController(title: "خطا", message: msg as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //print("Error. Wrong Code")
                
                }
                return
            }
            print(json)
            if (json.count >= 8) && (json.count <= 12) {
                //perform Segue to Profile
                if !self.oldUser {
                    self.defaults.set(json, forKey: "username")
                    self.defaults.set(self.phoneNo, forKey: "userMobile")
                    self.performSegue(withIdentifier: "showCompleteRegister", sender: nil)
                } else {
                    self.defaults.set(json, forKey: "username")
                    self.defaults.set(true, forKey: "loggedIn")
                    self.defaults.set(self.phoneNo, forKey: "userMobile")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    //self.navigationController?.viewControllers.removeAll()
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "mainTabbarVC")
                    self.present(initialViewController, animated: true, completion: {
                       /* var navArray:Array = (self.navigationController?.viewControllers)!
                        //navArray.remove(at: navArray.count-2)
                        navArray.removeAll()
                        self.navigationController?.viewControllers = navArray
                        //self.view.removeFromSuperview() */
                    })
                    
                }
            }
            
            
        }
        } else {
            print("Phone no or Code is wrong! ")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCompleteRegister" {
            let vc = segue.destination as! registerCompletionVC
            vc.mobilePhone = phoneNo
        }
    }
    
}
