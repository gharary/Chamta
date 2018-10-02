//
//  TabBar.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/15/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Crashlytics

class TabBar: UITabBarController, UIPopoverPresentationControllerDelegate {
    
    var indexPath: Int = 3
    var shouldUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(indexPath)
        // Do any additional setup after loading the view.
        self.tabBarController?.selectedIndex = indexPath
        
        // this is test
        
    }
 
    func presentPopOver() {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "updateVC")
        vc.modalPresentationStyle = .popover
        let popOver = vc.popoverPresentationController!
        popOver.delegate = self
        popOver.permittedArrowDirections = .init(rawValue: 0)
        popOver.sourceView = self.view
        popOver.sourceRect = CGRect(x: 200, y: 200, width: 0, height: 0)
        vc.preferredContentSize = CGSize(width: 250, height: 200)
        present(vc, animated: true, completion: nil)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
