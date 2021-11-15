//
//  SUTabBarViewController.swift
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
                title: "訂閱",
                image: UIImage(named: "Icons_64px_stack"),
                selectedImage: UIImage(named: "Icons_64px_stack")
            )

        case .statistics:
            return UITabBarItem(
                title: "統計",
                image: UIImage(named: "Icons_64px_PieChart"),
                selectedImage: UIImage(named: "Icons_64px_PieChart")
            )

        case .setting:
            return UITabBarItem(
                title: "設定",
                image: UIImage(named: "Icons_64px_setting"),
                selectedImage: UIImage(named: "Icons_64px_setting")
            )

        case .group:
            return UITabBarItem(
                title: "群組",
                image: UIImage(named: "Icons_64px_Group"),
                selectedImage: UIImage(named: "Icons_64px_GroupSelected")
            )
        }

    }

}

class SUTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.summary, .group, .statistics, .setting]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })
        delegate = self
        self.selectedIndex = 0
        
//        self.tabBar.barTintColor = UIColor.hexStringToUIColor(hex: "#94959A")
//        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = UIColor.hexStringToUIColor(hex: "#F6DF4F")
//        self.tabBar.unselectedItemTintColor = .white
        self.tabBarController?.tabBar.unselectedItemTintColor = .white

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.hexStringToUIColor(hex: "#94959A")
            
            appearance.compactInlineLayoutAppearance.normal.iconColor = .white
            appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            appearance.inlineLayoutAppearance.normal.iconColor = .white
            appearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            appearance.stackedLayoutAppearance.normal.iconColor = .white
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]

            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
    }

}
