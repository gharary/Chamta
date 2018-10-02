//
//  AboutUs.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/19/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire


class AboutUs: UIViewController {

    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    @IBOutlet weak var lawTextView: UITextView!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
    var telegramAddress: String = ""
    var instAddress: String = ""
    
    var VM_overlay : UIView = UIView()
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        callServer()
    }

    func callServer() {
        setupActivity()
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"aboutus"]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
                return
            }
            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                print("error parsing data. no data")
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
                return
            }
            self.activityIndicator.stopAnimating()
            self.VM_overlay.isHidden = true
            self.lawTextView.text = tempData[0]["app"] as? String
            self.addressLbl.text = tempData[0]["address"] as? String
            self.telegramAddress = (tempData[0]["telegram"] as? String)!
            self.instAddress = (tempData[0]["instagram"] as? String)!
        }
            
        
    }
    @IBAction func telegramBtnClicked(_ sender: UIButton) {
        
        var telegram = URL(string: telegramAddress)!
        
        if UIApplication.shared.canOpenURL(telegram) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(telegram, options: ["":""], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            //Telegram not Installed
            telegram = URL(string: telegramAddress)!
            UIApplication.shared.open(telegram, options: [:], completionHandler: nil)
            
        }
    }
    
    @IBAction func instaBtnClicked(_ sender: UIButton) {
        var instagram = URL(string: "instagram://user?username=\(instAddress)")!
        
        if UIApplication.shared.canOpenURL(instagram) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(instagram, options: ["":""], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                instagram = URL(string: "instagram.com/\(instAddress)")!
                UIApplication.shared.open(instagram, options: [:], completionHandler: nil)
            }
            
        } else {
            //Insta not Installed
            instagram = URL(string: "instagram.com/\(instAddress)")!
            UIApplication.shared.open(instagram, options: [:], completionHandler: nil)
            
            
        }
    }
    func setupActivity() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        VM_overlay = UIView(frame: UIScreen.main.bounds)
        //VM_overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: activityIndicator.bounds.size.width, height: activityIndicator.bounds.size.height)
        activityIndicator.center = VM_overlay.center
        VM_overlay.addSubview(activityIndicator)
        VM_overlay.center = view.center
        view.addSubview(VM_overlay)
        activityIndicator.startAnimating()
    }
    
    

}
