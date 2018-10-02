//
//  SplashVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 7/1/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class SplashVC: UIViewController, UIPopoverPresentationControllerDelegate {

    var shouldUpdate: Bool = false
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    var currentVer:String = ""
    var serveriOSVer: String = ""
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        checkUpdate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //shouldUpdate = true
        
    }

    func updateOrSegue() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            currentVer = version
        }
        if serveriOSVer > currentVer {
            presentPopOver()
        } else {
            performSegue(withIdentifier: "showMain", sender: self)
        }
        
    }
    func checkUpdate() {
        SVProgressHUD.showProgress(0.1, status: "در حال بارگذاری...")
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"aboutus"]
        
        
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            SVProgressHUD.showProgress(0.2, status: "در حال بارگذاری...")
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                SVProgressHUD.showError(withStatus: "Server Error Loading Shop Data")
                self.updateOrSegue()
                return
            }
            SVProgressHUD.showProgress(0.4, status: "در حال بارگذاری...")

            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                SVProgressHUD.showError(withStatus: "Shop Data Error")
                self.updateOrSegue()
                return
            }
            SVProgressHUD.showProgress(0.6, status: "در حال بارگذاری...")

            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                print("error parsing data. no data")
                SVProgressHUD.showError(withStatus: "Shop Data Error!")
                self.updateOrSegue()
                return
            }
            SVProgressHUD.showProgress(0.8, status: "در حال بارگذاری...")

            self.serveriOSVer = tempData[0]["ios"] as! String
            SVProgressHUD.showProgress(1, status: "در حال بارگذاری...")
            SVProgressHUD.dismiss(withDelay: 2.0)
            self.updateOrSegue()
            print(self.serveriOSVer)
            
        }
        
    }
    

    func presentPopOver() {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "updateVC")
        vc.modalPresentationStyle = .popover
        let popOver = vc.popoverPresentationController!
        popOver.delegate = self
        popOver.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popOver.sourceView = self.view
        popOver.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        vc.preferredContentSize = CGSize(width: 250, height: 200)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
