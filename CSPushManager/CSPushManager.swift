//
//  CSPushManager.swift
//  Push Testing
//
//  Created by Vedran on 03/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UserNotifications

class CSPushManager: NSObject {
    
    let kTxtMessageCategory = "txt_message_category"
    let kShareImage = "txt_share_image"
    let kShareUrl = "txt_share_url"
    
    public static let instance = CSPushManager()
    
    let bag = DisposeBag()
    
    // MARK: - Initialization Methods
    
    public func start(withApplication application: UIApplication) {
        print("Starting")
        UNUserNotificationCenter.current().delegate = self
        
        authorizationTrigger
            .filter{ $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                application.registerForRemoteNotifications()
                
            })
        .disposed(by: bag)
    }
    
    public func registeredForRemoteNotification(_ token: Data) {
        let deviceTokenString = token.reduce("") { $0 + String(format: "%02X", $1) }
        print("APNs device token: \(deviceTokenString)")
    }
    
    lazy var authorizationTrigger: Single<Bool> = {
        return Single.create(subscribe: { observer in
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound],
                                                                    completionHandler: { granted, error in
                                                                        if error == nil, granted {
                                                                            observer(.success(true))
                                                                        } else {
                                                                            observer(.success(false))
                                                                        }
            })
            
            return Disposables.create()
        })
    }()
    
    
    // MARK: - Category Builders
    
    var textMessageCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: kTxtMessageCategory,
                                      actions: [replyAction, openInAppAction, dismissAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    var imageShareCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: kShareImage,
                                      actions: [replyAction, openInAppAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    var urlShareCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: kShareUrl,
                                      actions: [replyAction, openUrlAction, openInAppAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    
    // MARK: - Action Builders
    
    var replyAction: UNNotificationAction {
        return UNTextInputNotificationAction(identifier: "REPLY", title: "Quick Reply", options: [])
    }
    
    var openInAppAction: UNNotificationAction {
        return UNNotificationAction(identifier: "VIEW", title: "View", options: [.foreground])
    }
    
    var dismissAction: UNNotificationAction {
        return UNNotificationAction(identifier: "DISMISS", title: "Dismiss", options: [.destructive])
    }
    
    var openUrlAction: UNNotificationAction {
        return UNNotificationAction(identifier: "OPEN_URL", title: "Open Url", options: [.destructive])
    }
    
}

extension CSPushManager: UNUserNotificationCenterDelegate {
    
}


