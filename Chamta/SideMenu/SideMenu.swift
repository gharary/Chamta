//
//  SideMenu.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/15/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit

class SideMenu: UITableViewController {

    let defaults = UserDefaults.standard
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var appBuildLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let login = defaults.object(forKey: "loggedIn")
        {
            if login as? Bool == true {
                editProfileCell.isUserInteractionEnabled = true
                editProfileCell.alpha = 1.0
                editProfileCell.contentView.alpha = 1.0
            
            }
        }
        appVersionUIView()
        
        
    }

    func appVersionUIView() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String , let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String{
            appBuildLabel.text = "\(version) (\(build))"
        }
        
        
        
    }
    @IBOutlet weak var editProfileCell: UITableViewCell!
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        switch indexPath.row {
        case 1:
            print("Profile Clicked!")
            performSegue(withIdentifier: "showProfile", sender: nil)
            
        case 2:
            performSegue(withIdentifier: "showProfile", sender: nil)
            print("Login Clicked!")
        case 3:
            performSegue(withIdentifier: "showProfile", sender: nil)
            print("Pishnehadat Clicked!")
        case 4:
            performSegue(withIdentifier: "showProfile", sender: nil)
            print("AboutUs Clicked!")
        default:
            print("Something Clicked!")
        }
        */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            let dc = segue.destination as? TabBar
            dc?.indexPath = 3
            
            
        }
    }
   
}
