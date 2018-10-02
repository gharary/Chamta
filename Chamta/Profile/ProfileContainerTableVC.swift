//
//  ProfileContainerTableVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/11/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit

class ProfileContainerTableVC: UITableViewController {

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            //print("Share App Clicked!")
            let username = defaults.object(forKey: "username")
            let usernameStr: String = username as! String
            let message = "سلام. یه پیشنهاد شگفت انگیز دارم برات. چمتا رو نصب کن ! کد معرف: \(usernameStr)"
            //Set the link to share.
            if let link = NSURL(string: "http://chamtaa.com")
            {
                let objectsToShare = [message,link] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                self.present(activityVC, animated: true, completion: nil)
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
}
