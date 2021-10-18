//
//  ViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

private enum Tab {
    
    case summary
    
    case setting
    
    case statistics
    
    case group
    
    func controller() -> UIViewController {
        
        var controller: UIViewController

        switch self {
            
        case .summary: controller = UIStoryboard.summary.instantiateInitialViewController()!
          
        case .statistics: controller = UIStoryboard.statistics.instantiateInitialViewController()!
            
        case .setting: controller = UIStoryboard.setting.instantiateInitialViewController()!
            
        case .group: controller = UIStoryboard.group.instantiateInitialViewController()!
            
        }
        
        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
        
        return controller

    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .summary:
            return UITabBarItem(
                title: nil,
                image: UIImage(systemName: "rectangle.stack"),
                selectedImage: UIImage(systemName: "rectangle.stack.fill")
            )

        case .statistics:
            return UITabBarItem(
                title: nil,
                image: UIImage(systemName: "chart.pie"),
                selectedImage: UIImage(systemName: "chart.pie.fill")
            )

        case .setting:
            return UITabBarItem(
                title: nil,
                image: UIImage(systemName: "gearshape"),
                selectedImage: UIImage(systemName: "gearshape.fill")
            )

        case .group:
            return UITabBarItem(
                title: nil,
                image: UIImage(systemName: "person.3"),
                selectedImage: UIImage(systemName: "person.3.fill")
            )
        }

    }

}

class SUTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.setting, .summary, .statistics, .group]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })
        delegate = self
    }

}
