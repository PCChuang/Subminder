//
//  Double+Extension.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/27.
//

import Foundation

extension Double {

    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
