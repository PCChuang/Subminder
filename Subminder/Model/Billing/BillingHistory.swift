//
//  BillingHistory.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/13.
//

import Foundation

struct BillingHistory: Codable {
    
    var id: String
    var groupID: String
    var userUID: String
    var hostUID: String
    var paymentDate: Date
    var paymentAmount: Decimal
    var note: String
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case groupID
        case userUID
        case hostUID
        case paymentDate
        case paymentAmount
        case note
    }
    
    var toDict: [String: Any] {
        
        return [
            "id": id as Any,
            "groupID": groupID as Any,
            "userUID": userUID as Any,
            "hostUID": hostUID as Any,
            "paymentDate": paymentDate as Any,
            "paymentAmount": paymentAmount as Any,
            "note": note as Any
        ]
    }
}
