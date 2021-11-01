//
//  Encodable+Extension.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/29.
//

import Foundation

extension Encodable {
  func asDictionary() throws -> [String: Any] {

    let data = try JSONEncoder().encode(self)

    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {

      throw NSError()
    }

    return dictionary
  }
}
