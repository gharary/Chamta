//
//  registerCompletionVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/26/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire

class registerCompletionVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var familyTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var phoneNoTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var emailTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var addressTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var birthdayTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var introCodeTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var registerBtn: UIButton!
    
    
    
    var showKeyboard:Bool = false
    var offsetY:CGFloat = 0
    var textFields: [SkyFloatingLabelTextField] = []
    var segueString: String = ""
    var mobilePhone: String = ""
    var receivedData = Data()
    var defaults = UserDefaults.standard
    var window: UIWindow?
    
    
    let lightGreyColor: UIColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor: UIColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor:UIColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        familyTF.becomeFirstResponder()
        textFieldDidChange(textField: familyTF)
        if mobilePhone == "" {
            mobilePhone = defaults.value(forKey: "userMobile") as! String
        }
        callServerForUsername()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFields = [familyTF, phoneNoTF, emailTF, addressTF,birthdayTF, introCodeTF]
        setupTextFields()
        
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
        }
    }
    
    @IBAction func registerCompleteBtn(_ sender: UIButton) {
        if (familyTF.text == "" || phoneNoTF.text == "" || addressTF.text == "" ) {
            let alert = UIAlertController(title: "error", message: "Fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //testSubmitClick()
            submitToServer()
        }
    }
    func testSubmitClick() {
        performSegueToReturnBack()
    }
    func submitToServer() {
        var birthday = ""
        let username = defaults.object(forKey: "username")
        if !(birthdayTF.text?.isEmpty)! {
            birthday = (birthdayTF.text?.replacingOccurrences(of: "/", with: "-"))!
        }
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"register", "home_phone":phoneNoTF.text!, "address":addressTF.text!, "phone":mobilePhone, "email":emailTF.text!, "name":familyTF.text!, "code":introCodeTF.text!, "birth":birthday , "username":username!]
        
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            self.receivedData = response.data!
            
            guard let json = response.result.value as? Int else {
                
                return
                
            }
            //print(json)
            
            if json == 1 {
                let alert = UIAlertController(title: "تبریک", message: "اطلاعات شما با موفقیت ثبت شد!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: {
                action in
                    
                    //Show main VC
                    /*
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
                    //self.performSegueToReturnBack()
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                self.defaults.set(true, forKey: "loggedIn")
                self.defaults.set(self.mobilePhone, forKey: "userMobile")
                self.present(alert, animated: true, completion: nil)
                
                
                
            }
        }
    }

    
    @IBAction func TextFieldEditingBegin(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.calendar = NSCalendar(identifier: NSCalendar.Identifier.persian) as Calendar?
        datePickerView.locale = NSLocale(localeIdentifier: "fa_IR") as Locale?
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.calendar = Calendar(identifier: .persian)
        
        let date = dateFormatter.string(from: sender.date)
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        birthdayTF.text = date
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        registerBtn.layer.cornerRadius = 5
        registerBtn.layer.borderWidth = 3
        registerBtn.layer.borderColor = registerBtn.backgroundColor?.cgColor
        if (familyTF.text == "" || phoneNoTF.text == ""  || addressTF.text == "") {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            registerBtn.alpha = 0.5
            registerBtn.isEnabled = false
            
        } else {
            
            if ( (familyTF.errorMessage == "" || familyTF.errorMessage == nil) && (phoneNoTF.errorMessage == "" || phoneNoTF.errorMessage == nil) && (addressTF.errorMessage == "" || addressTF.errorMessage == nil)) {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                registerBtn.isEnabled = true
                registerBtn.alpha = 1
                
            } else {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
                registerBtn.isEnabled = false
                registerBtn.alpha = 0.5
                
                
            }
        }
        
    }
    
    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }
   
    func setupTextFields() {
        familyTF.becomeFirstResponder()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        familyTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        phoneNoTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        emailTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        addressTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        birthdayTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        registerBtn.isEnabled = false
        
        for textField in textFields {
            applySkyscannerThemeWithIcon(textField: textField as! SkyFloatingLabelTextFieldWithIcon)
            textField.delegate = self
            textField.isLTRLanguage = false
        }
        familyTF.placeholder = "نام و نام خانوادگی (الزامی)"
        familyTF.title = "نام خانوادگی"
        familyTF.iconText = "\u{f007}"
        
        emailTF.placeholder = "آدرس ایمیل"
        emailTF.title = "ایمیل"
        emailTF.iconText = "\u{f003}"
        
        phoneNoTF.placeholder = "شماره تلفن ثابت‌ (الزامی)"
        phoneNoTF.title = "تلفن ثابت"
        phoneNoTF.iconText = "\u{f095}"
        
        addressTF.placeholder = "آدرس دقیق منزل یا محل کار (جهت ارسال خرید)"
        addressTF.title = "آدرس شما"
        addressTF.iconText = "\u{f278}"
        
        birthdayTF.placeholder = "تاریخ تولد خود را وارد نمائید"
        birthdayTF.title = "تاریخ تولد"
        birthdayTF.iconText = "\u{f271}"
        
        introCodeTF.placeholder = "اگر کد معرف دارید اینجا وارد کنید"
        introCodeTF.title = "کد معرف"
        introCodeTF.iconText = "\u{f234}"

    }
    

    func applySkyscannerThemeWithIcon(textField: SkyFloatingLabelTextFieldWithIcon) {
        
        //print(textField)
        self.applySkyscannerTheme(textField: textField)
        
        textField.iconColor = lightGreyColor
        textField.selectedIconColor = overcastBlueColor
        textField.iconFont = UIFont(name: "FontAwesome", size: 15)
        textField.titleLabel.font = UIFont(name: "IRANSANSMOBILE", size: 15)
        textField.placeholderFont = UIFont(name: "IRANSANSMOBILE-Light", size: 15)
        
    }
    
    func applySkyscannerTheme(textField: SkyFloatingLabelTextField) {
        
        textField.tintColor = overcastBlueColor
        textField.textColor = darkGreyColor
        textField.lineColor = lightGreyColor
        textField.selectedTitleColor = overcastBlueColor
        textField.selectedLineColor = overcastBlueColor
        
        //Set custom fonts for title, plcaholder and textfield labels
        textField.titleLabel.font = UIFont(name: "IRANSANSMOBILE", size: 12)
        textField.placeholderFont = UIFont(name: "IRANSANSMOBILE-Light", size: 18)
        textField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        
        
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTF {
            validateEmailField()
        }
        return true
        
    }
    
    
    func validateEmailField() {
        validateEmailTextFieldWithText(email: emailTF.text)
    }
    
    func validateEmailTextFieldWithText(email: String?) {
        guard let email = email else {
            emailTF.errorMessage = nil
            return
        }
        
        if email.isEmpty {
            emailTF.errorMessage = nil
        } else if !validateEmail(candidate: email) {
            emailTF.errorMessage = NSLocalizedString(
                "ایمیل نامعتبر",
                tableName: "SkyFloatingLabelTextField",
                comment: " "
            )
        } else {
            emailTF.errorMessage = nil
        }
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
}
