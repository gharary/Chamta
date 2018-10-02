//
//  PishnehadVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/20/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

class PishnehadVC: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var descTF: UITextView!
    
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTF.becomeFirstResponder()
        
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderWidth = 3
        submitButton.layer.borderColor = submitButton.backgroundColor?.cgColor
        
        // Do any additional setup after loading the view.
    }

    @IBAction func submitBtn(_ sender: UIButton) {
        
        if let name = nameTF.text, !name.isEmpty, let phone = phoneTF.text, !phone.isEmpty, let desc = descTF.text, !desc.isEmpty {
            callServer(name, phone, desc)
            
        } else {
            let alert = UIAlertController(title: "خطا", message: "همه فیلدها باید پر شود", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func callServer(_ name:String, _ phone:String, _ desc: String) {
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        
        let parameters: Parameters = ["action":"connectus","phone":phone, "name":name, "text":desc]
        
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            
            guard let json = response.result.value as? Int else {
                
                print("error parsing JSON")
                
                return
                
            }
            //print(json)
            
            if json == 1 {
                let alert = UIAlertController(title: "تبریک", message: "نظرات شما با موفقیت ثبت شد!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: {
                    action in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        
    }
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    

}
