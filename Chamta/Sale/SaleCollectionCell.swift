//
//  SaleCollectionCell.swift
//  Chamta
//
//  Created by Mohammad Gharari on 12/27/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit

class SaleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productPriceOld: UILabel!
    @IBOutlet weak var productPriceNew: UILabel!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = self.frame.size.width * 0.100
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        //self.layer.backgroundColor = UIColor.blue.cgColor
    }
}
