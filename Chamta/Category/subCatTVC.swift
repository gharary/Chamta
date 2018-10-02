//
//  subCatTVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 3/8/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "subCatCell"
class subCatTVC: UITableViewController, UITabBarControllerDelegate {

    
    @IBOutlet weak var tblView: UITableView!
    
    
    let defaults: UserDefaults = UserDefaults.standard
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    var VM_overlay : UIView = UIView()
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    var catID: String = ""
    var receivedData = Data()
    var categories:[Categories] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        receivedData = Data()
        
        callServer()
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
    
    func callServer() {
        setupActivity()
        
        let headers:HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"category", "id":catID]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            self.receivedData = response.data!
            self.parseJSON()
            //self.performSegue(withIdentifier: "checkCodeVC", sender: nil)
            
        }
    }
    
    func parseJSON() {
        activityIndicator.stopAnimating()
        VM_overlay.isHidden = true
        do {
            let jsonDecoder = JSONDecoder()
            self.categories = try jsonDecoder.decode([Categories].self, from: receivedData)
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            let alert = UIAlertController(title: "خطا", message: "چیزی یافت نشد", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                self.performSegueToReturnBack()
            }))
            //self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) //as! subCatTVCell
        
//        var dictionary: [Categories] = []
//        dictionary = categories
        

        // Configure the cell...

        cell.backgroundColor = UIColor.white
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSubCatProduct", sender: nil)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSubCatProduct" {
            //let indexPaths : NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            //let indexPath: NSIndexPath = indexPaths[0] as! NSIndexPath
            let indexPath = self.tblView.indexPathForSelectedRow
            if let navigation = segue.destination as? UINavigationController ,let dc = navigation.topViewController as? ProductCollectionVC {
                dc.filterString = categories[(indexPath?.row)!].name
                dc.shouldFilter = true
                dc.showSubCatData = true
                dc.segueString = "subCategory"
                
            } else {
                print("Navigation didn't poped!")
            }
        } else {
            print("Segue Didn't performed!")
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
