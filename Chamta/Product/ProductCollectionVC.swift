//
//  ProductCollectionVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/18/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "ProductCell"



class ProductCollectionVC: UICollectionViewController {
    @IBOutlet var productCollectionView: UICollectionView!
    var receivedData = Data()
    var products:[Products] = []
    let defaults: UserDefaults = UserDefaults.standard
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject]!
    var imageData: Array<UIImage> = []
    var imgData:Dictionary<Int,UIImage> = [:]
    
    var cache:NSCache<AnyObject, AnyObject>!
    
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableData = []
        self.cache = NSCache()
        receivedData = Data()
        
        //refreshTableView()
        //callServer()
        callServerAlamo()
    }
    
    func callServerAlamo() {
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"select","rpp":"10","pn":"1"]
        let request = Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.refreshCtrl.endRefreshing()
                return
            }
            
            //let data = response.data
            self.receivedData = response.data!
            self.parseJSON()
            /*do {
                
                let jsonDecoder = JSONDecoder()
                self.products = try jsonDecoder.decode([Products].self, from: data!)
                DispatchQueue.main.async {
                    self.productCollectionView.reloadData()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            } */
        }
        //debugPrint(request)
    }
    func parseJSON() {
        do {
            let jsonDecoder = JSONDecoder()
            self.products = try jsonDecoder.decode([Products].self, from: receivedData)
            DispatchQueue.main.async {
                self.productCollectionView.reloadData()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
}
    func callServer() {
        
        
        var request = URLRequest(url: baseUrl!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        //let postString = ["action":"select","rpp":"10","pn":"1"]
        let paramString = "action=select&rpp=10&pn=1"
        //request.httpBody = postString.data(using: .utf8)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: paramString, options: [])
            //request.httpBody = paramString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let jsonData = data, error == nil else {
                print("error =\(String(describing: error))")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but it is \(httpStatus.statusCode)")
                print("Response = \(String(describing: response))")
            }
            do {
                
                
                let jsonDecoder = JSONDecoder()

                
                let transform = "Any-Hex/Java"
                let input = "msg\":\"\\u062f\\u0631\\u062e\\u0648\\u0627\\u0633\\u062a \\u0646\\u0627 \\u0645\\u0639\\u062a\\u0628\\u0631" as NSString
                let convertedString = input.mutableCopy() as! NSMutableString
                CFStringTransform(convertedString, nil, transform as NSString, true)
                print("ConvertedString: \(convertedString)")
                
                
                self.products = try jsonDecoder.decode([Products].self, from: jsonData)
               
                DispatchQueue.main.async {
                    
                    self.productCollectionView?.reloadData()
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
            task.resume()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return products.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionCell
    
        // Configure the cell
        cell.productLabel.text = products[indexPath.row].name
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
