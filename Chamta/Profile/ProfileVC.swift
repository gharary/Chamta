//
//  ProfileVC.swift
//  Chamta
//
//  Created by Mohammad Gharari on 1/11/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var familyLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var offSave: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    let defaults = UserDefaults.standard
    let baseUrl = URL(string: "http://www.chamtaa.com/service/route.php")
    
    
    var tableData: [AnyObject]!
    var profile : Profile? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let login:Bool = defaults.bool(forKey: "loggedIn")
        if !login {
            let storyboard = UIStoryboard(name: "Register", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginSignupVC")
            self.present(initialViewController, animated: true, completion: nil)
        } else {
            self.tableData = []
            getUserData()
        }
        if let imageData = defaults.object(forKey: "profilePicture") {
            let imageUIImage: UIImage = UIImage(data: imageData as! Data)!
            profilePicture.image = imageUIImage
        }
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
       let login:Bool = defaults.bool(forKey: "loggedIn")
        if login {
            self.tableData = []
            getUserData()
        }
    }
    func getUserData() {
        guard let mobile = defaults.object(forKey: "userMobile") as? String, !mobile.isEmpty else {
            defaults.set(false, forKey: "loggedIn")
            let storyboard = UIStoryboard(name: "Register", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginSignupVC")
            self.present(initialViewController, animated: true, completion: nil)
            return
        }
        //print(mobile)
        let headers: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let parameters: Parameters = ["action":"profile", "phone":mobile]
        
        
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
                print("error parsing data. no data")
                return
            }
            
            for data in tempData {
                self.tableData.append(data)
            }
            
            let tblData = self.tableData[0] as! [String:AnyObject]
            
            self.profile = Profile(id: tblData["id"] as? String, name: tblData["name"] as? String, phone: tblData["phone"] as? String, home_phone: tblData["home_phone"] as? String, address: tblData["address"] as? String, email: tblData["email"] as? String, sms_code: tblData["sms_code"] as? String, off: tblData["off"] as? String, username: tblData["username"] as? String, date: tblData["date"] as? String, num_buy: tblData["num_buy"] as? String, buys: tblData["buys"] as? String, birth: tblData["birth"] as? String )
            self.setupFields()
            
        }
    }
    
    func setupFields() {
        familyLbl.text = profile?.name
        mobileLbl.text = profile?.phone
        offSave.text = profile?.off
        let usrName = profile?.username
        emailLbl.text = "کد اشتراک:  \(usrName!)"
        phoneLbl.text = profile?.home_phone
        addressLbl.text = profile?.address
        
        profilePicture.layer.cornerRadius = 5
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.borderColor = UIColor(red: 182.0/255.0, green: 35.0/255.0, blue: 47.0/255.0, alpha: 1).cgColor
        
    }
    
    @IBAction func imageBtnPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "اضافه کردن عکس از:", message: "", preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: "گالری", style: .default, handler: { (action) in
            //execute some code
            self.useCameraRoll()
            
        }))
        
        alert.addAction(UIAlertAction(title: "دوربین", style: .default, handler: { (action) in
            self.useCamera()
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    func useCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            //newMedia = true
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func useCameraRoll() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            //newMedia = false
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        profilePicture.image = image
        let img = image.resizedTo100K()
        let imageData: Data = UIImagePNGRepresentation(img!)!
        defaults.set(imageData, forKey: "profilePicture")
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        profilePicture.image = image
        let img = image.resizedTo100K()
        let imageData: Data = UIImagePNGRepresentation(img!)!
        defaults.set(imageData, forKey: "profilePicture")
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func logOutBtn(_ sender: UIBarButtonItem) {
        let login:Bool = defaults.bool(forKey: "loggedIn")
        
        
        let alert = UIAlertController(title: "اخطار!", message: "آیا مطمئن هستید میخواهید از پروفایلتان خارج شوید؟", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "بلی!", style: .destructive, handler: { (action) in
            if login {
                
                self.defaults.set(false, forKey: "loggedIn")
                self.defaults.removeObject(forKey: "profilePicture")
                self.profilePicture.image = UIImage(named: "picture")
                let storyboard = UIStoryboard(name: "Register", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginSignupVC")
                self.present(initialViewController, animated: true, completion: nil)
            } else {
                let storyboard = UIStoryboard(name: "Register", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginSignupVC")
                self.present(initialViewController, animated: true, completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "نه!", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    //let myThumb1 = myPicture.resized(withPercentage: 0.1)
    //let myThumb2 = myPicture.resized(toWidth: 72.0)
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resizedTo100K() -> UIImage? {
        guard let imageData = UIImagePNGRepresentation(self) else {return nil}
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 512.0
        
        while imageSizeKB > 512.0 {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.8), let imageData = UIImagePNGRepresentation(resizingImage) else {return nil}
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 512.0
            
        }
        return resizingImage
    }
}


