//
//  errorHandling.swift
//  Chamta
//
//  Created by Mohammad Gharari on 2/18/18.
//  Copyright © 2018 Mohammad Gharari. All rights reserved.
//

import Foundation

enum errorEnum : String, Codable {
    
    case ecEnum
    case msgEnum
}

struct Error:Codable {
    let ec:String
    let msg:String
}
