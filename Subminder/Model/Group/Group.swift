//
//  Group.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/5.
//

import Foundation

struct Group: Codable {

    var id: String
    var name: String
    var image: String
    var hostUID: String
    var userUIDs: [String]
    var subscriptionName: String

    enum CodingKeys: String, CodingKey {

        case id
        case name
        case image
        case hostUID
        case userUIDs
        case subscriptionName
    }
    
    var toDict: [String: Any] {

        return [
            "id": id as Any,
            "name": name as Any,
            "image": image as Any,
            "hostUID": hostUID as Any,
            "userUIDs": userUIDs as Any,
            "subscriptionName": subscriptionName as Any
        ]
    }
}
