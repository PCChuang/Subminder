//
//  String+Extension.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/27.
//

import UIKit

extension String {

    func deletePrefix(_ prefix: String) -> String {

        guard self.hasPrefix(prefix) else { return self }

        return String(self.dropFirst(3))
    }
}
