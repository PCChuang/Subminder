//
//  UITableViewCell+Extension.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/23.
//

import Foundation
import UIKit

extension UITableViewCell {
    
    static var identifier: String {
        
        return String(describing: self)
    }
}
