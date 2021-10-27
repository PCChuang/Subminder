//
//  Decimal+Extension.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/27.
//

import Foundation

extension Decimal {

    var doubleValue: Double {

            return NSDecimalNumber(decimal: self).doubleValue
        }
}
