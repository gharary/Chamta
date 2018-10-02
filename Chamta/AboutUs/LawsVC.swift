//
//  LawsVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 2/19/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

class LawsVC: UIViewController {

    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    @IBOutlet weak var lawTextView: UITextView!
    
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
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
            self.lawTextView.text = tempData[0]["laws"] as? String
            
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
