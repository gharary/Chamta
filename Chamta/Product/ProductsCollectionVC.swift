//
//  ProductCollectionVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/18/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SkeletonView

private let reuseIdentifier = "ProductCell"



class ProductCollectionVC: UICollectionViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UISearchResultsUpdating {
   
    @IBOutlet var productCollectionView: UICollectionView!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    let defaults: UserDefaults = UserDefaults.standard
    let columns: CGFloat = 2.0
    let inset: CGFloat = 8.0
    let spacing: CGFloat = 8.0
    let lineSpacing:CGFloat = 8.0
    let searchController = UISearchController(searchResultsController: nil)
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    
    var showSubCatData:Bool = false
    var searchTerm = ""
    var shouldFilter: Bool = false
    var filterString: String = ""
    var cache:NSCache<AnyObject, AnyObject>!
    var receivedData = Data()
    var VM_overlay : UIView = UIView()
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    var products:[Products]!
    {
        didSet{
            self.productCollectionView?.reloadData()
        }
    }
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject]!
    var imageData: Array<UIImage> = []
    var imgData:Dictionary<Int,UIImage> = [:]
    var searchData:[Products]!
    var endOfData:Bool = false
    var indexAllData = 1
    var indexSearch = 0
    var indexSubCat = 1
    var indexSearchSubCat = 0
    var loadMoreStatus = false
    var segueString: String = ""
    var shoppingList:[shoppingItems] = []
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        //Load Shopping Basket items
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
            
        }
        //Load Buttons for Navigation
        
         if !shouldFilter {
            let shopItem = UIBarButtonItem.init(image: UIImage(named: "shopping"), style: .done, target: self, action: #selector(shopTapped))
            let searchItem = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
            navBar.leftBarButtonItems = [shopItem, searchItem]
            
            
         } else {
            let searchItem = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
            let shopItem = UIBarButtonItem.init(image: UIImage(named: "shopping"), style: .done, target: self, action: #selector(shopTapped))
            let backButton = UIBarButtonItem.init(image: UIImage(named: "back"), style: .done, target: self, action: #selector(returnBack(_:)))
            navBar.leftBarButtonItems = [backButton, shopItem, searchItem]
        }
        
        if showSubCatData {
            callServerAlamoSubCat()
        } else {
            callServerAlamo()
        }
        
    }
    @objc func searchTapped() {
        performSegue(withIdentifier: "showSearch", sender: nil)
    }
    @objc func shopTapped() {
        performSegue(withIdentifier: "showShoppingList", sender: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.products = []
        self.tableData = []
        self.cache = NSCache()
        receivedData = Data()
        refreshCtrl = UIRefreshControl()
        
        
        self.searchData = []
        
        //setupSearchController()
        setupRefreshControll()
    }

    
    func setupRefreshControll() {
        
        
        refreshCtrl.addTarget(self, action: #selector(loadDataRefresh), for: .valueChanged)
        productCollectionView?.refreshControl = refreshCtrl
    }
    
    @objc func loadDataRefresh() {
        self.products = []
        self.tableData = []
        self.cache = NSCache()
        receivedData = Data()
        self.searchData = []
        self.indexAllData = 1
        self.indexSearch = 0
        self.indexSubCat = 1
        self.indexSearchSubCat = 0
        if showSubCatData {
            callServerAlamoSubCat()
        } else {
            callServerAlamo()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadDataRefresh()
        self.collectionView?.reloadData()
    }
    @objc func returnBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func filterContent(for searchText: String) {
        requestSearchFromServer(term: searchText)
        collectionView?.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
        } else {
            collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == products.count - 1 {
            
            
            if searchController.searchBar.text != "" {
                if showSubCatData {
                    indexSearchSubCat += 1
                    self.loadMoreDataSubCat(indexSearchSubCat, searchTerm)
                } else {
                    indexAllData += 1
                    self.loadMoreData(indexAllData)
                }
            } else if showSubCatData {
                indexSubCat += 1
                self.loadMoreDataSubCat(indexSubCat, "")
            } else {
                indexAllData += 1
                self.loadMoreData(indexAllData)
            }
            
        }
    }
    
    
    func loadMoreDataSubCat(_ index:Int, _ term:String) {
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters =
        ["action":"search","rpp":"10","pn":"\(index)","search":term,"c_name":filterString]
        
        //["action":"search","rpp":"10","pn":"\(index)","category":filterString,"search":term]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                self.refreshCtrl.endRefreshing()
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
                self.refreshCtrl.endRefreshing()
                return
            }
            
            let newData:[Products]
            let dataReceived : Data = response.data!
            //self.receivedData = response.data!
        
            do {
                let jsonDecoder = JSONDecoder()
                newData = try jsonDecoder.decode([Products].self, from: dataReceived)
                
                for item in newData {
                    if self.searchController.searchBar.text != "" {
                        self.searchData.append(item)
                    } else {
                        self.products.append(item)
                    }
                }
                self.collectionView?.reloadData()

            } catch let error as NSError {
                print(error.localizedDescription)
            
                self.endOfData = true
            }
        }
    }
    func loadMoreData(_ index:Int) {
        var headers: HTTPHeaders = [:]
        var parameters: Parameters = [:]
        if searchController.searchBar.text != "" {
            
            if segueString == "subCategory" && shouldFilter {
                
                headers = ["Content-Type":"application/x-www-form-urlencoded"]
                parameters = ["action":"search","rpp":"10","pn":"1","search":searchTerm,"c_name":filterString]
            } else {
                
                
                headers = ["Content-Type":"application/x-www-form-urlencoded"]
                parameters = ["action":"search","rpp":"10","pn":"1","search":searchTerm]
            }
            
        } else {
            headers = ["Content-Type":"application/x-www-form-urlencoded"]
            parameters = ["action":"select","rpp":"10","pn":"\(index)"]
        }
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                self.refreshCtrl.endRefreshing()
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
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
                    if self.searchController.searchBar.text != "" {
                        self.searchData.append(item)
                    } else {
                        self.products.append(item)
                    }
                }
                //self.collectionView?.reloadData()
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
                self.endOfData = true
            }
            
            
        }
    }
    func requestSearchFromServer(term: String) {
        self.searchTerm = term
        var headers: HTTPHeaders = [:]
        var parameters: Parameters = [:]
        if segueString == "subCategory" && shouldFilter {
            
             headers = ["Content-Type":"application/x-www-form-urlencoded"]
            parameters = ["action":"search","rpp":"10","pn":"1","search":term,"c_name":filterString]
        } else {

        
             headers = ["Content-Type":"application/x-www-form-urlencoded"]
             parameters = ["action":"search","rpp":"10","pn":"1","search":term]
        }
        
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.refreshCtrl.endRefreshing()
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
                return
            }
            
            //let data = response.data
            self.receivedData = response.data!
            self.parseJSONSearch()
        }
        
    }
    
    
    func setupSearchController() {
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "دنبال چی میگردی؟"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        
        searchController.searchBar.setValue("انصراف", forKey:"_cancelButtonText")
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black]
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "جستجوی کالاها", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        
        let titleTextAttributesSelected = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
        
        //Normal Text
        let titleTextAttributesNormal = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
        
        if let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.font = UIFont(name: "IRANSansMobile-Light", size: 14.0)
            textFieldInsideSearchBar.textAlignment = .center
            
            if let backgroundView = textFieldInsideSearchBar.subviews.first {
                //background color
                backgroundView.backgroundColor = .white
                
                //rounded corner
                backgroundView.layer.cornerRadius = 10
                backgroundView.clipsToBounds = true
                
                
            }
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
            
        }
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
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
        //setupActivity()

        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"select","rpp":"10","pn":"1"]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.refreshCtrl.endRefreshing()
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
                return
            }
            //let data = response.data
            self.receivedData = response.data!
            self.parseJSON()

        }
        //debugPrint(request)
    }
    func callServerAlamoSubCat() {
        //setupActivity()
        
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"search","rpp":"10","pn":"1","category":filterString]
        
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.refreshCtrl.endRefreshing()
                self.activityIndicator.stopAnimating()
                self.VM_overlay.isHidden = true
                return
            }
            
            self.receivedData = response.data!
            
            self.parseJSONSubCat()
        }

    }
    
    func parseJSONSubCat() {
        self.refreshCtrl.endRefreshing()
        activityIndicator.stopAnimating()
        VM_overlay.isHidden = true
        
        searchData = []
        do {
            let jsonDecoder = JSONDecoder()
            
            self.products = try jsonDecoder.decode([Products].self, from: receivedData)
            
            DispatchQueue.main.async {
                self.productCollectionView.reloadData()
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            let alert = UIAlertController(title: "خطا", message: "چیزی یافت نشد", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                //self.performSegueToReturnBack()
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    func parseJSONSearch() {
        self.refreshCtrl.endRefreshing()
        activityIndicator.stopAnimating()
        VM_overlay.isHidden = true
        searchData = []
        do {
            let jsonDecoder = JSONDecoder()
            
            //self.products = try jsonDecoder.decode([Products].self, from: receivedData)
            self.searchData = try jsonDecoder.decode([Products].self, from: receivedData)

            DispatchQueue.main.async {
                self.productCollectionView.reloadData()
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            let alert = UIAlertController(title: "خطا", message: "چیزی یافت نشد", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                //self.performSegueToReturnBack()
                self.dismiss(animated: true, completion: nil)
            }))
            //self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func parseJSON() {
        self.refreshCtrl.endRefreshing()
        activityIndicator.stopAnimating()
        VM_overlay.isHidden = true
        searchData = []
        do {
            let jsonDecoder = JSONDecoder()
            
            self.products = try jsonDecoder.decode([Products].self, from: receivedData)
            
            
            DispatchQueue.main.async {
                self.productCollectionView.reloadData()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            let alert = UIAlertController(title: "خطا", message: "چیزی یافت نشد", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) in
                //self.performSegueToReturnBack()
                self.dismiss(animated: true, completion: nil)
            }))
            //self.present(alert, animated: true, completion: nil)
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if searchController.searchBar.text != "" && searchData.count > 0 {
            return searchData.count
        } else {
            return products.count
        }
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return reuseIdentifier
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionCell
    
        var dictionary: [Products] = []
        if searchController.searchBar.text != "" && searchData.count > 0 {
            dictionary = searchData
        } else {
            dictionary = products
        }
        // Configure the cell
        cell.productLabel.text = dictionary[indexPath.row].name
        if products[indexPath.row].on_sale == "1" {
            
            let imageView: UIImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 45, height: 45))
            
            let image: UIImage = #imageLiteral(resourceName: "SaleRed")
            imageView.image = image
            imageView.contentMode = .scaleToFill
            cell.contentView.addSubview(imageView)
            
        }
        cell.productPrice.text = dictionary[indexPath.row].f_c_cell
        var photoUrl:String = "http://chamtaa.com/login/"
        if dictionary[indexPath.row].image != nil {
            photoUrl.append((dictionary[indexPath.row].image)!)
            let url:URL! = URL(string: photoUrl)
            cell.productImage.kf.indicatorType = .activity
            cell.productImage.kf.setImage(with: url, options: [.transition(.fade(0.4))])
            
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "ShowProductDetail", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProductDetail" {
            let indexPaths : NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            let indexPath: NSIndexPath = indexPaths[0] as! NSIndexPath
            //print(segue.destination)
            if let navigation = segue.destination as? UINavigationController ,let dc = navigation.topViewController as? ProductDetail {
                if products[indexPath.row].title != nil { dc.desc = products[indexPath.row].title! }
                //dc.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
                dc.price = products[indexPath.row].f_c_cell!
                dc.name = products[indexPath.row].name!
                dc.weight = products[indexPath.row].weight!
                dc.id = products[indexPath.row].id!
                dc.entity = Float(products[indexPath.row].num!)!
                dc.id = products[indexPath.row].id!
                
                
            } else {
                print("Navigation didn't poped!")
            }
        } else if segue.identifier == "showSearch" {
            if let dc = segue.destination as? SearchCollectionVC {
                dc.subCatString = filterString
                dc.showSubCatData = showSubCatData
            }
        } else {
            print("Segue Didn't performed!")
        }
        
    }

}


extension ProductCollectionVC: UICollectionViewDelegateFlowLayout {
    
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
