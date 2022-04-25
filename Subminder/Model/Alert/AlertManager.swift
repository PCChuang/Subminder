//
//  AlertManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2022/4/22.
//

import UIKit

public class AlertManager {
    
    public static func simpleConfirmAlert(in viewController: UIViewController? = nil,
                                          title: String? = nil, message: String? = nil,
                                          confirmTitle: String = "確認",
                                          handler: (() -> Void)? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { _ in handler?() }))
        
        return alert
    }
    
    public static func submitConfirmAlert(in viewController: UIViewController? = nil,
                                          title: String? = nil, message: String? = nil,
                                          confirmTitle: String = "確認",
                                          confirmHandler: (() -> Void)? = nil,
                                          cancelTitle: String = "取消",
                                          cancelHandler: (() -> Void)? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { _ in confirmHandler?() }))
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in cancelHandler?() }))
        
        return alert
    }
}
