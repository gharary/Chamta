//
//  SaleCollectionVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/27/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "saleCell"

class SaleCollectionVC: UICollectionViewController {
    
    @IBOutlet weak var saleCollectionView: UICollectionView!
    @IBOutlet weak var basketShop: UIBarButtonItem!
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    let columns: CGFloat = 2.0
    let inset: CGFloat = 8.0
    let spacing: CGFloat = 8.0
    let lineSpacing:CGFloat = 8.0
    let defaults = UserDefaults.standard
    
    var cache:NSCache<AnyObject, AnyObject>!
    var receivedData = Data()
    var VM_overlay : UIView = UIView()
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    var products:[Products]!
    {
        didSet{
            self.saleCollectionView.reloadData()
        }
    }
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject]!
    var imageData: Array<UIImage> = []
    var imgData:Dictionary<Int,UIImage> = [:]
    var searchData:[Products]!
    var endOfData:Bool = false
    var indexOfPage = 1
    var shoppingList:[shoppingItems] = []
    
    override func viewDidAppear(_ animated: Bool) {
        basketShop.addBadge(number: shoppingList.count)
        if products.isEmpty {
            callServerAlamo()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.products = []
        self.refreshCtrl = UIRefreshControl()
        self.cache = NSCache()
        receivedData = Data()
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
            basketShop.addBadge(number: shoppingList.count)
        }
        
    }

    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == products.count - 1 {
            indexOfPage += 1
            if !endOfData {
                loadMoreData(indexOfPage)
            }
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
    
    func callServerAlamo() {
        setupActivity()
        
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"filtering","rpp":"10","pn":"1"]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.refreshCtrl.endRefreshing()
                return
            }
            
            //let data = response.data
            self.receivedData = response.data!
            self.parseJSON()
            
        }
        //debugPrint(request)
    }
    func parseJSON() {
        activityIndicator.stopAnimating()
        VM_overlay.isHidden = true
        do {
            let jsonDecoder = JSONDecoder()

            self.products = try jsonDecoder.decode([Products].self, from: receivedData)
            
            DispatchQueue.main.async {
                self.saleCollectionView.reloadData()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            let alert = UIAlertController(title: "خطا", message: "چیزی یافت نشد", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                //self.performSegueToReturnBack()
                //self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    func loadMoreData(_ index:Int) {
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"filtering","rpp":"10","pn":"\(index)"]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.refreshCtrl.endRefreshing()
                return
            }
            
            let newData:[Products]
            //let data = response.data
            self.receivedData = response.data!
            do {
                let jsonDecoder = JSONDecoder()
                
                newData = try jsonDecoder.decode([Products].self, from: self.receivedData)
                for item in newData {
                    self.products.append(item)
                }
                //self.collectionView?.reloadData()
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
                self.endOfData = true
            }
            
            
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return products.count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showProductDetail", sender: nil)
        
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SaleCollectionCell
    
        // Configure the cell
        cell.productLabel.text = products[indexPath.row].name
        cell.productPriceNew.text = products[indexPath.row].f_c_cell
        cell.productPriceOld.text = products[indexPath.row].f_cell
        if products[indexPath.row].on_sale == "1" {
            
            let imageView: UIImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 25, height: 25))
            
            let image: UIImage = #imageLiteral(resourceName: "SaleRed")
            imageView.image = image
            cell.contentView.addSubview(imageView)
            
            
            let string = products[indexPath.row].f_cell
            
            let attributes = [
                NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue,
                NSAttributedStringKey.foregroundColor : UIColor.red
                ] as [NSAttributedStringKey : Any]
            
            let richText = NSAttributedString(string: string! , attributes: attributes )
             cell.productPriceOld.attributedText =  richText
            
            
        }
        var photoUrl:String = "http://chamtaa.com/login/"
        if products[indexPath.row].image != nil {
            photoUrl.append((products[indexPath.row].image)!)
            
            let url: URL! = URL(string: photoUrl)
            cell.productImage.kf.indicatorType = .activity
            cell.productImage.kf.setImage(with: url)
        }
        
        
       
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetail" {
            let indexPaths: NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            let indexPath: NSIndexPath = indexPaths[0] as! NSIndexPath
            
            if let nav = segue.destination as? UINavigationController, let dc = nav.topViewController as? ProductDetail {
                dc.desc = products[indexPath.row].title!
                dc.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
                dc.price = products[indexPath.row].f_c_cell!
                dc.name = products[indexPath.row].name!
                dc.weight = products[indexPath.row].weight!
                dc.id = products[indexPath.row].id!
                dc.entity = Float(products[indexPath.row].num!)!
            }
            else if let dc = segue.destination as? ProductDetail {
                dc.entity = Float(products[indexPath.row].num!)!
                    dc.desc = products[indexPath.row].title!
                    dc.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
                    dc.price = products[indexPath.row].f_c_cell!
                    dc.name = products[indexPath.row].name!
                    dc.weight = products[indexPath.row].weight!
                dc.id = products[indexPath.row].id!
            } else {
                print("Segue didn't performed! ")
                
            }
        }
    }

}
extension SaleCollectionVC: UICollectionViewDelegateFlowLayout {
    
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
