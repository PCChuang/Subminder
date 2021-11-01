//
//  ProfileItem.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/28.
//

import UIKit

protocol ProfileItem {

    var title: String? { get }
}

enum PersonalItem: ProfileItem {

    case subscription

    case friend

    case group

    var title: String? {

        switch self {

        case .subscription: return "訂閱"

        case .friend: return "好友"

        case .group: return "群組"
        }
    }
}
