//
//  Payable.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/10.
//

import Foundation

struct Payable: Codable {
    
    var id: String
    var groupID: String
    var userUID: String
    var amount: Decimal
    var nextPaymentDate: Date
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case groupID
        case userUID
        case amount
        case nextPaymentDate
    }
    
    var toDict: [String: Any] {
        
        return [
            "id": id as Any,
            "groupID": groupID as Any,
            "userUID": userUID as Any,
            "amount": amount as Any,
            "nextPaymentDate": nextPaymentDate as Any
        ]
    }
}
