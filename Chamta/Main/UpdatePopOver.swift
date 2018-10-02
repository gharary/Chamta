//
//  UpdatePopOver.swift
//  Chamta
//
//  Created by Mohammad Gharari on 7/1/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Crashlytics

class UpdatePopOver: UIViewController {

    @IBOutlet weak var urlButton: UIButton!
    let url = URL(string: "https://new.sibapp.com/applications/chamta")
    override func viewDidLoad() {
        super.viewDidLoad()

        urlButton.layer.cornerRadius = 5
        urlButton.layer.borderColor = urlButton.backgroundColor?.cgColor
        urlButton.layer.borderWidth = 3
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openUrl(_ sender: UIButton) {
        //Crashlytics.sharedInstance().crash()
        UIApplication.shared.open(url!, options: [:])
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
