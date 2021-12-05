//
//  SubscriptionProvider.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/24.
//

import Foundation

class SubscriptionProvider {
    
    enum TextFieldInfo {
        
        case name
        
        case price
        
        case currency
        
        case firstPaymentDate
        
        case cycle
        
        case duration
        
        case reminder
        
        case color
        
        case note
    }
    
    enum GroupTextFieldInfo {
        
        case name
        
        case groupName
        
        case price
        
        case currency
        
        case sharedAmount
        
        case firstPaymentDate
        
        case cycle
        
        case duration
        
        case reminder
        
        case color
        
        case note
    }
    
    let subscriptionConstructor: [TextFieldInfo] = [
        .name,
        .price,
        .currency,
        .firstPaymentDate,
        .cycle,
        .duration,
        .reminder,
        .color,
        .note
    ]
    
    let groupSubscriptionConstructor: [GroupTextFieldInfo] = [
        .name,
        .groupName,
        .price,
        .currency,
        .sharedAmount,
        .firstPaymentDate,
        .cycle,
        .duration,
        .reminder,
        .color,
        .note
    ]

    var subscription: Subscription
    
    init(subscription: Subscription) {
        
        self.subscription = subscription
    }
    
    var subSettings: [String] = [
        
        "名稱",
        "金額",
        "幣別",
        "第一次付款日",
        "付款週期",
        "訂閱週期",
    //    "分類",
        "付款提醒",
        "顏色",
        "備註"
    ]
    
    var groupSubSettings: [String] = [
        
        "名稱",
        "群組",
        "總金額",
        "幣別",
        "平攤金額",
        "第一次付款日",
        "約定付款週期",
        "訂閱週期",
        "付款提醒",
        "顏色",
        "備註"
    ]
    
    func publish(with subscription: inout Subscription) {

        guard let userUID = KeyChainManager.shared.userUID else { return }

        subscription.userUID = userUID

        SubsManager.shared.publishSub(subscription: &subscription) { result in

            switch result {

            case .success:

                print("onTapPublish, success")

            case .failure(let error):

                print("publishSub.failure: \(error)")
            }
        }
    }
    
    func save(with subscription: inout Subscription) {
        
        guard let userUID = KeyChainManager.shared.userUID else { return }

        subscription.userUID = userUID

        SubsManager.shared.saveEditedSub(subscription: &subscription, subscriptionID: subscription.id) { result in

            switch result {

            case .success:

                print("onTapSave, success")

            case .failure(let error):

                print("saveSub.failure: \(error)")
            }
        }
    }
    
    func delete() {

        SubsManager.shared.deleteSub(subscription: subscription) { result in
            
            switch result {

            case .success:

                print("onTapDelete, success")

            case .failure(let error):

                print("deleteSub.failure: \(error)")
            }
        }
    }
    
    func publishInBatch(userUIDs: [String], hostUID: String, with subscription: inout Subscription) {
        
        SubsManager.shared.publishInBatch(userUIDs: userUIDs, hostUID: hostUID, subscription: &subscription) { result in

            switch result {

            case .success:

                print("onTapPublish, success")

            case .failure(let error):

                print("publishSub.failure: \(error)")
            }
        }
    }
}
