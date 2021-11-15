//
//  Subscription.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/20.
//

import Foundation

struct Subscription: Codable {

    var userUID: String
    var id: String
    var name: String
    var price: Decimal
    var currency: String
    var exchangePrice: Double
    var startDate: Date
    var dueDate: Date
    var cycle: String
    var duration: String
    var category: String
    var color: String
    var reminder: String
    var note: String
    var groupID: String
    var groupName: String
    var groupPriceTotal: Decimal
    var groupMemberCount: Int

    enum CodinKeys: String, CodingKey {

        case userUID
        case id
        case name
        case price
        case exchangePrice
        case currency
        case startDate
        case dueDate
        case cycle
        case duration
        case category
        case color
        case reminder
        case note
        case groupID
        case groupName
        case groupPriceTotal
        case groupMemberCount
    }

    var toDict: [String: Any] {

        return [
            "userUID": userUID as Any,
            "id": id as Any,
            "name": name as Any,
            "price": price as Any,
            "exchangePrice": exchangePrice as Any,
            "currency": currency as Any,
            "startDate": startDate as Any,
            "dueDate": dueDate as Any,
            "cycle": cycle as Any,
            "duration": duration as Any,
            "category": category as Any,
            "color": color as Any,
            "reminder": reminder as Any,
            "note": note as Any,
            "groupID": groupID as Any,
            "groupName": groupName as Any,
            "groupPriceTotal": groupPriceTotal as Any,
            "groupMemberCount": groupMemberCount as Any
        ]
    }
}
