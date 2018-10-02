//
//  ProductDetail.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/19/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import ImageSlideshow
import Alamofire
import AlamofireImage

class ProductDetail: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let defaults = UserDefaults.standard
    
    @IBOutlet weak var basketShop: UIBarButtonItem!
    @IBOutlet weak var imageSlider: ImageSlideshow!
    //@IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var productDesc: UITextView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    //@IBOutlet weak var productWeight: UILabel!
    //@IBOutlet weak var productAmount: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var productEntity: UILabel!
    @IBOutlet weak var amountTF: UITextField!
    
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")

    
    var pickerOptionK = Array(0...20)
    let pickerOptionG = Array(arrayLiteral: 0,100,200,300,400,500,600,700,800,900)
    var pickerOptionKiloStr = "کیلوگرم"
    let pickerOptionGramStr = "گرم"
    var shoppingList:[shoppingItems] = []
    var remoteStore = [InputSource]()
    var id: String? = ""
    var desc: String = "توضیحات ندارد."
    var image: UIImage? = UIImage(named: "picture.png")
    var image2: UIImage? = UIImage(named: "picture.png")
    var name: String = ""
    var price: String = ""
    var i:Int = 0
    var itemsInBasket :[Any] = []
    var weight:String = ""
    var amount: Float = 0
    var entity: Float = 0
    var segueString: String = ""
    var imgData: String = ""
    var imgData2: String = ""
    var receivedData = Data()
    var product: Products? = nil
    override func viewDidAppear(_ animated: Bool) {
        basketShop.addBadge(number: shoppingList.count)
        
        
        
        
    }
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        //itemsInBasket = defaults.array(forKey: "itemsInCart")!
        if let data = defaults.value(forKey: "shoppingList") as? Data {
            shoppingList = try! PropertyListDecoder().decode(Array<shoppingItems>.self, from: data)
        }
        if segueString == "segueFromShoppingList" {
            callServer()
        } else {
            callServerAlamo()
        }
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        amountTF.inputView = pickerView
        pickerOptionKiloStr = weight
    }
    func DataSetup() {
        productDesc.text = desc
        productName.text = name
        productPrice.text = "\(price) تومان"
        if weight != "کیلو" {
            
        
            productEntity.text = String(Int(entity)) + "  " + weight
        } else {
            productEntity.text = String(entity) + "  " + weight
        }
        let localEntity = Int(entity)
        if localEntity < 20 {
            pickerOptionK = Array(0...localEntity)
        }
        
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderWidth = 3
        submitButton.layer.borderColor = submitButton.backgroundColor?.cgColor
    }
    func imageSliderSetup() {
        self.imageSlider.backgroundColor = UIColor.white
        self.imageSlider.slideshowInterval = 3.0
        self.imageSlider.pageIndicatorPosition = .init(horizontal: .center , vertical: .bottom)
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
        pageIndicator.pageIndicatorTintColor = UIColor.black
        imageSlider.pageIndicator = pageIndicator
        self.imageSlider.contentScaleMode = .scaleToFill
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageSlider.addGestureRecognizer(gestureRecognizer)
        
    }
    @objc func didTap() {
        imageSlider.presentFullScreenController(from: self)
        
    }
    
    func getSliderImageKF() {
        DataSetup()
        let image = UIImage(named: "placeholder")
        var photoUrl:String = "http://chamtaa.com/login/"
        var photoUrl2: String = "http://chamtaa.com/login/"
        if !imgData.isEmpty {
            photoUrl.append(imgData)
            self.remoteStore.append(KingfisherSource(urlString: photoUrl)!)
            let imgUrl = URL(string: photoUrl)
            let imageView = UIImageView()
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imgUrl ,placeholder: image ,options: [.onlyFromCache])
            self.image = imageView.image
            self.imageSlider.setImageInputs(self.remoteStore)
            
        }
        
        if !imgData2.isEmpty {
            photoUrl2.append(imgData2)
            photoUrl2.append("png")
            self.remoteStore.append(KingfisherSource(urlString: photoUrl2)!)
            self.imageSlider.setImageInputs(self.remoteStore)
            /*
            let imgUrl = URL(string: photoUrl)
            let imageView = UIImageView()
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imgUrl , placeholder: image )//,options: [.onlyFromCache])
            self.image = imageView.image
            */
        }
        self.imageSliderSetup()
    }
    
    
    func getSliderImage() {
        DataSetup()
        var photoUrl:String = "http://chamtaa.com/login/"
        var photoUrl2: String = "http://chamtaa.com/login/"
        //if product?.image != nil {
        if !imgData.isEmpty {
            photoUrl.append(imgData)
            let url:URL! = URL(string: photoUrl)
            let task = URLSession.shared.downloadTask(with: url, completionHandler: {(location, response, error) in
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async(execute: {() -> Void in
                        let img: UIImage! = UIImage(data: data)
                        if img != nil {
                            self.remoteStore.append(ImageSource(image: img))
                            self.imageSlider.setImageInputs(self.remoteStore)
                            self.image = img
                            self.imageSliderSetup()
                            
                        }
                    })
                }
            })
            task.resume()
        }
        //if product?.image2 != nil {
        if !imgData2.isEmpty {
            photoUrl2.append(imgData2)
            let url:URL! = URL(string: photoUrl2)
            let task = URLSession.shared.downloadTask(with: url, completionHandler: {(location, response, error) in
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async(execute: {() -> Void in
                        let img: UIImage! = UIImage(data: data)
                        if img != nil {
                            self.remoteStore.append(ImageSource(image: img))
                            self.imageSlider.setImageInputs(self.remoteStore)
                            self.image2 = img
                        }
                    })
                }
            })
            task.resume()
        }
        
        
        
    }
    
    func callServer() {
        let id = self.id!
        print(id)
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"select","id":"\(id)"]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                return
            }
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject]  else {
                
                print("error parsing Data, No Data!")
                return
                
            }
            /*
 
             productDesc.text = desc
             productName.text = name
             productPrice.text = "\(price) تومان"
             productWeight.text = weight
             productAmount.text = String(amount)
             productEntity.text = String(entity)
        */
            self.desc = (tempData[0]["title"] as? String)!
            self.name = (tempData[0]["name"] as? String)!
            self.price = (tempData[0]["f_c_cell"] as? String)!
            self.entity = Float((tempData[0]["num"] as? String)!)!
            
            self.imgData = (tempData[0]["image"] as? String ?? "")
            self.imgData2 = (tempData[0]["image2"] as? String ?? "")
            self.getSliderImageKF()
        }
    }
    func callServerAlamo() {
        let id = self.id!
        print(id)
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"select","id":"\(id)"]
        Alamofire.request(baseUrl!,method: .post ,parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                
                return
            }
            guard let jsonResult = response.result.value as? [[String:Any]] else {
                print("error parsing jsonResult!")
                return
            }
            guard let tempData:[AnyObject] = jsonResult as? [AnyObject] else {
                
                print("error parsing Data, No Data!")
                return
                
            }
            self.imgData = (tempData[0]["image"] as? String ?? "")
            self.imgData2 = (tempData[0]["image2"] as? String ?? "")
            self.getSliderImageKF()
        }
        
    }
    
    func parseJSON() {
        do {
            let jsonDecoder = JSONDecoder()
            self.product = try jsonDecoder.decode(Products.self, from: receivedData)
            getSliderImageKF()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    @IBAction func TextFieldEditingBegin(_ sender: UITextField) {
        
        
        //let amountPicker:UIPickerView = UIPickerView()
        

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if !weight.isEmpty {
            if weight != "کیلو" {
                return 2
            } else {
                return 4
            }
            
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerOptionK.count
        } else if component == 1 {
            return 1
        } else if component == 2 {
            return pickerOptionG.count
        } else {
            return 1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        
        let pickerLabel = UILabel()
        if component == 0 {
            let richText = NSMutableAttributedString(string: String(pickerOptionK[row]), attributes: [.paragraphStyle : style, NSAttributedStringKey.font:UIFont(name: "IRANSANSMOBILE", size: 20.0)!])//,NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue ])
            pickerLabel.attributedText = richText
            return pickerLabel
            
        } else if component == 1 {
            let richText = NSMutableAttributedString(string: String(pickerOptionKiloStr), attributes: [.paragraphStyle : style, NSAttributedStringKey.font:UIFont(name: "IRANSANSMOBILE", size: 20.0)!])
            pickerLabel.attributedText = richText
            return pickerLabel
            
        } else if component == 2 {
            let richText = NSMutableAttributedString(string: String(pickerOptionG[row]), attributes: [.paragraphStyle : style, NSAttributedStringKey.font:UIFont(name: "IRANSANSMOBILE", size: 20.0)!])
            pickerLabel.attributedText = richText
            return pickerLabel
        } else {
            let richText = NSMutableAttributedString(string: String(pickerOptionGramStr), attributes: [.paragraphStyle : style, NSAttributedStringKey.font:UIFont(name: "IRANSANSMOBILE", size: 20.0)!])
            pickerLabel.attributedText = richText
            return pickerLabel
        }
        
    }
    /*
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            let titleData = String(pickerOptionK[row])
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "IRANSANSMOBILE", size: 14.0)!])
            return myTitle
            
        } else if component == 1{
            let titleData = String(pickerOptionKiloStr)
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "IRANSANSMOBILE", size: 14.0)!])
            return myTitle
            
        } else if component == 2 {
            let titleData = String(pickerOptionG[row])
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "IRANSANSMOBILE", size: 14.0)!])
            return myTitle
        } else {
            let titleData = String(pickerOptionGramStr)
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "IRANSANSMOBILE", size: 14.0)!])
            return myTitle
        }
    }*/
    /*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(pickerOptionK[row])"
        } else if component == 1{
            return "\(pickerOptionKiloStr)"
        } else if component == 2 {
            return "\(pickerOptionG[row])"
        } else {
            return "\(pickerOptionGramStr)"
            }
        }*/
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.numberOfComponents > 2 {
            let kilo = pickerOptionK[pickerView.selectedRow(inComponent: 0)]
            let gram = pickerOptionG[pickerView.selectedRow(inComponent: 2)]
            
            amountTF.text = "\(kilo).\(gram)"
            pickerView.reloadAllComponents()
            
        } else {
            let kilo = pickerOptionK[pickerView.selectedRow(inComponent: 0)]
            amountTF.text = "\(kilo)"
            pickerView.reloadAllComponents()
        }
        
         
            
        
        
    }
    
    /*
    @IBAction func increaseBtn(_ sender: UIButton) {
        
        if amount < entity {
            amount += 1
            productAmount.text = String(amount)
        }
    }
    
    @IBAction func decreaseBtn(_ sender: UIButton) {
        amount -= 1
        if amount >= 0 {
            productAmount.text = String(amount)
        } else {
            amount = 0
            productAmount.text = String(amount)
        }
    }
    */
    @IBAction func addToBasketBtn(_ sender: UIButton) {
        if !(amountTF.text?.isEmpty)! {
        //if amount > 0 {
            let id:String = self.id!
            let num:Float = Float(self.amountTF.text!)!
            let name:String = self.name
            let price:Float = Float(self.price)!
            if self.image != nil {
                defaults.set(UIImagePNGRepresentation(self.image!), forKey: id)
            }
            
            let item:shoppingItems = shoppingItems(id: id, num: num, name: name, price: price)
            if let i = shoppingList.index(where: {$0.id == id }) {
                
                print("item Already Exist!")
                shoppingList.remove(at: i)
            }
            shoppingList.append(item)
            defaults.set(try? PropertyListEncoder().encode(shoppingList), forKey: "shoppingList")
            basketShop.addBadge(number: shoppingList.count)
        } else {
            let alert = UIAlertController(title: "خطا", message: "لطفا مقدار کالا را مشخص کنید", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }

}
extension UIPickerView {
    
    func setPickerLabels(labels: [Int:UILabel], containedView: UIView) { // [component number:label]
        
        let fontSize:CGFloat = 20
        let labelWidth:CGFloat = containedView.bounds.width / CGFloat(self.numberOfComponents)
        let x:CGFloat = self.frame.origin.x
        let y:CGFloat = (self.frame.size.height / 2) - (fontSize / 2)
        
        for i in 0...self.numberOfComponents {
            
            if let label = labels[i] {
                
                if self.subviews.contains(label) {
                    label.removeFromSuperview()
                }
                
                label.frame = CGRect(x: x + labelWidth * CGFloat(i), y: y, width: labelWidth, height: fontSize)
                label.font = UIFont.boldSystemFont(ofSize: fontSize)
                label.backgroundColor = .clear
                label.textAlignment = NSTextAlignment.center
                
                self.addSubview(label)
            }
        }
    }
}
