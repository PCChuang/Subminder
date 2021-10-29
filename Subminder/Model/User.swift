//
//  User.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/20.
//

import Foundation

struct User: Codable {

    var id: String
    var name: String
    var email: String
    var image: String
    var friendList: [String]
    var groupList: [String]
    var subList: [String]
    var payable: Decimal
    var receivable: Decimal
    var currency: String

    enum CodinKeys: String, CodingKey {

        case id
        case name
        case email
        case image
        case friendList
        case groupList
        case subList
        case payable
        case receivable
        case currency
    }

    var toDict: [String: Any] {

        return [
            "id": id as Any,
            "name": name as Any,
            "email": email as Any,
            "image": image as Any,
            "friendList": friendList as Any,
            "groupList": groupList as Any,
            "subList": subList as Any,
            "payable": payable as Any,
            "receivable": receivable as Any,
            "currency": currency as Any
        ]
    }
}
