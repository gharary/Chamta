//
//  MainVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/15/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    @IBAction func showTabBar(_ sender: UIButton) {
        performSegue(withIdentifier: "showTabbar", sender: nil)
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTabbar" {
            let dc = segue.destination as? TabBar
            dc?.indexPath = 2
            
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
