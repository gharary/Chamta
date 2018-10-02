//
//  SearchCollectionVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 3/11/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "ProductCell"

class SearchCollectionVC: UICollectionViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UISearchResultsUpdating {
    
    

    private let image = UIImage(named: "negative")?.withRenderingMode(.alwaysTemplate)
    private let topMessage = "Search"
    private let bottomMessage = "You don't have any items to show."
    @IBOutlet weak var productCV: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    
    let defaults:UserDefaults = UserDefaults.standard
    let columns:CGFloat = 2.0
    let inset: CGFloat = 8.0
    let spacing: CGFloat = 8.0
    let lineSpacing:CGFloat = 8.0
    let searchController = UISearchController(searchResultsController: nil)
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    
    var searchTerm:String = ""
    var searchData:[Products]!
    {
        didSet{
            self.productCV.reloadData()
        }
    }
    var endData:Bool = false
    var indexSearch = 0
    var showSubCatData:Bool = false
    var subCatString:String = ""
    var shoppingList:[shoppingItems] = []
    var receivedData = Data()
    var VM_Overlay: UIView = UIView()
    var activityIndc: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
            
        }
        self.collectionView?.backgroundView = UIView()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchData = []
        receivedData = Data()
        
        setupSearchController()
        barButtonSetup()
        
        
        

    }

    func barButtonSetup() {
        let backButton = UIBarButtonItem.init(image: UIImage(named: "back"), style: .done, target: self, action: #selector(returnBack(_:)))
        navBar.leftBarButtonItems = [backButton]
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //self.dismiss(animated: true, completion: nil)
        performSegueToReturnBack()
    }
    @objc func returnBack(_ sender: UIBarButtonItem) {
        //self.dismiss(animated: true, completion: nil)
        performSegueToReturnBack()
    }
    func setupSearchController(){
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = ""
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
        
        activityIndc = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        VM_Overlay = UIView(frame: UIScreen.main.bounds)
        //VM_overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndc.frame = CGRect(x: 0, y: 0, width: activityIndc.bounds.size.width, height: activityIndc.bounds.size.height)
        activityIndc.center = VM_Overlay.center
        VM_Overlay.addSubview(activityIndc)
        VM_Overlay.center = view.center
        view.addSubview(VM_Overlay)
        activityIndc.startAnimating()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
        } else {
            collectionView?.reloadData()
        }
    }
    
    func filterContent(for searchText: String) {
        requestSearchServer(term: searchText)
        self.productCV.reloadData()
    }

    
    func requestSearchServer(term: String) {
        self.searchTerm = term
        var headers: HTTPHeaders = [:]
        var parameters: Parameters = [:]
        
        if showSubCatData {
            headers = ["Content-Type":"application/x-www-form-urlencoded"]
            parameters = ["action":"search","rpp":"50","pn":"1","search":term,"c_name":subCatString]
        } else {
            headers = ["Content-Type":"application/x-www-form-urlencoded"]
            parameters = ["action":"search","rpp":"50","pn":"1","search":term]
        }
        
        Alamofire.request(baseUrl!, method: .post, parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.activityIndc.stopAnimating()
                self.VM_Overlay.isHidden = true
                return
            }
            
            //Get Data and Send to Parse
            self.receivedData = response.data!
            self.parseJSONSearch()
            
            
        }
        
    }
    
    func parseJSONSearch() {
        activityIndc.stopAnimating()
        VM_Overlay.isHidden = true
        searchData = []
        do {
            let jsonDecoder = JSONDecoder()
            self.searchData = try jsonDecoder.decode([Products].self, from: receivedData)
            
            DispatchQueue.main.async {
                self.productCV.reloadData()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            
            
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if searchData.count == 0 {
            self.collectionView?.setEmptyMessage("چیزی یافت نشد!!")
        } else {
            self.collectionView?.restore()
        }
        return searchData.count //> 0 ? searchData.count : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionCell
        
        var dictionary: [Products] = searchData
        
        cell.productLabel.text = dictionary[indexPath.row].name
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProductDetail" {
            let indexPaths: NSArray = self.collectionView?.indexPathsForSelectedItems! as! NSArray
            let indexPath : NSIndexPath = indexPaths[0] as! NSIndexPath
            
            if let nav = segue.destination as? UINavigationController, let dc = nav.topViewController as? ProductDetail {
                if searchData[indexPath.row].title != nil { dc.desc = searchData[indexPath.row].title! }
                //dc.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
                dc.price = searchData[indexPath.row].f_c_cell!
                dc.name = searchData[indexPath.row].name!
                dc.weight = searchData[indexPath.row].weight!
                dc.id = searchData[indexPath.row].id!
                dc.entity = Float(searchData[indexPath.row].num!)!
                dc.id = searchData[indexPath.row].id!
            }
        }
    }

}
extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "IRANSANSMOBILE", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension SearchCollectionVC: UICollectionViewDelegateFlowLayout {
    
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

