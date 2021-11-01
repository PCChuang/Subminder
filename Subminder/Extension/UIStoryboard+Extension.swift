//
//  UIStoryboard+Extension.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

private struct StoryboardCategory {

    static let main = "Main"

    static let summary = "Summary"

    static let statistics = "Statistics"

    static let setting = "Setting"

    static let group = "Group"
}

extension UIStoryboard {

    static var main: UIStoryboard { return suStoryboard(name: StoryboardCategory.main) }

    static var summary: UIStoryboard { return suStoryboard(name: StoryboardCategory.summary) }

    static var statistics: UIStoryboard { return suStoryboard(name: StoryboardCategory.statistics) }

    static var setting: UIStoryboard { return suStoryboard(name: StoryboardCategory.setting) }

    static var group: UIStoryboard { return suStoryboard(name: StoryboardCategory.group) }

    private static func suStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }

}
