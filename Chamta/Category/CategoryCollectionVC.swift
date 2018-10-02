//
//  CategoryCollectionViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/16/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire
import SkeletonView
import Crashlytics

private let reuseIdentifier = "CatCell"
typealias JSONDictionary = [String: Any]


let columns: CGFloat = 3.0
let inset: CGFloat = 8.0
let spacing: CGFloat = 8.0
let lineSpacing:CGFloat = 8.0


class CategoryCollectionVC: UICollectionViewController,UITabBarControllerDelegate {

    
    @IBOutlet var catCollectionView: UICollectionView!
    @IBOutlet weak var basketShop: UIBarButtonItem!
    
    var categories:[Categories] = []
    let defaults: UserDefaults = UserDefaults.standard
    var refreshCtrl: UIRefreshControl!
    var VM_overlay : UIView = UIView()
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    var shoppingList:[shoppingItems] = []
    
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
   
    override func viewDidAppear(_ animated: Bool) {
        
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
            basketShop.addBadge(number: shoppingList.count)
        }
     
        if categories.isEmpty {
            callServer()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshCtrl = UIRefreshControl()
        
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
            basketShop.addBadge(number: shoppingList.count)
        }
        
        if #available(iOS 11, *) {
            self.refreshCtrl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
            self.catCollectionView.refreshControl = refreshCtrl
        } else {
            self.refreshCtrl = UIRefreshControl()
            self.collectionView?.addSubview(refreshCtrl)
            self.collectionView?.alwaysBounceVertical = true
        }

    }
    
    
    @objc func refreshTableView() {

        callServer()
    }
    func callServer() {
        setupActivity()
        
        var request = URLRequest(url: baseUrl!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "action=category"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let jsonData = data, error == nil else {
                print("error =\(String(describing: error))")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.VM_overlay.isHidden = true
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but it is \(httpStatus.statusCode)")
                print("Response = \(String(describing: response))")
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
                return
            }
            do {
                
            
                let jsonDecoder = JSONDecoder()
                
                self.categories = try jsonDecoder.decode([Categories].self, from: jsonData)
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.VM_overlay.isHidden = true
                    self.refreshCtrl.endRefreshing()
                    self.catCollectionView.reloadData()
                    
                }
            } catch let error as NSError {
                self.refreshCtrl.endRefreshing()
                print(error.localizedDescription)
            }
        }
        task.resume()
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "دسته بندی"
        defaults.removeObject(forKey: "filterSubGroup")
        
    }

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSubCategory", sender: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "CatCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CategoryCollectionCell
    
        
        // Configure the cell
        
        cell.backgroundColor = UIColor.white
        cell.catLabel.text = categories[indexPath.row].name
        
        var photoUrl:String = "http://chamtaa.com/login/"
        if categories[indexPath.row].icon != nil {
            photoUrl.append((categories[indexPath.row].icon)!)
            
            let url:URL! = URL(string: photoUrl)
            cell.catImageView.kf.indicatorType = .activity
            cell.catImageView.kf.setImage(with: url)
        }
        
        return cell
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdenfierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "CatCell"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSubCategory" {
            let indexPaths : NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            let indexPath : NSIndexPath = indexPaths[0] as! NSIndexPath
            let dc = segue.destination as! subCatTVC
            dc.catID = categories[indexPath.row].id
           
        }
    }

    
}
public protocol SkeletonCollectionViewDataSource: UICollectionViewDataSource {
    func numSections(in collectionSkeletonView: UICollectionView) -> Int
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier
}

extension CategoryCollectionVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int((collectionView.frame.width / columns) - (inset + spacing))
        // let height = Int(collectionView.frame.height / 2)
        
        return CGSize(width: width, height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    
}


