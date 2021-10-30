//
//  Request.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/29.
//

import Foundation

struct Request: Codable {

    var to: String
    var from: String

    enum CodingKeys: String,CodingKey {

        case to
        case from
    }

    var toDict: [String: Any] {

        return [
            "to": to as Any,
            "from": from as Any
        ]
    }
}
