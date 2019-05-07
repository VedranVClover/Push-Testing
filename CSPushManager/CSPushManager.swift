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

typealias SendTokenToApiCompletion = (Error) -> Void

class CSPushManager: NSObject {
    
    // MARK: - VARIABLES
    
    public static let instance = CSPushManager()
    
    let bag = DisposeBag()
    
    
    // MARK: - INITIALIZATION
    
    public func start(withApplication application: UIApplication) {
        print("Starting")
        UNUserNotificationCenter.current().delegate = self
        
        authorizationTrigger
            .filter{ $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] _ in
                application.registerForRemoteNotifications()
                UNUserNotificationCenter.current().setNotificationCategories([self.textMessageCategory,
                                                                              self.imageShareCategory,
                                                                              self.videoShareCategory,
                                                                              self.urlShareCategory])
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
    
    
    // MARK: - CATEGORIES
    
    var textMessageCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: CSPushConstants.txtMessageCategory,
                                      actions: [replyAction, viewInAppAction, dismissAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    var videoShareCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: CSPushConstants.shareVideo,
                                      actions: [replyAction, viewInAppAction, dismissAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    var imageShareCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: CSPushConstants.shareImage,
                                      actions: [replyAction, viewInAppAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    var urlShareCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: CSPushConstants.shareUrl,
                                      actions: [replyAction, openUrlAction, viewInAppAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    
    // MARK: - ACTIONS
    
    var replyAction: UNNotificationAction {
        return UNTextInputNotificationAction(identifier: CSPushConstants.replyAction, title: "Reply", options: [])
    }
    
    var viewInAppAction: UNNotificationAction {
        return UNNotificationAction(identifier: CSPushConstants.viewAction, title: "View", options: [.foreground])
    }
    
    var dismissAction: UNNotificationAction {
        return UNNotificationAction(identifier: CSPushConstants.dismissAction, title: "Dismiss", options: [.destructive])
    }
    
    var openUrlAction: UNNotificationAction {
        return UNNotificationAction(identifier: CSPushConstants.openUrlAction, title: "Open Url", options: [.destructive])
    }
    
}

// MARK: - HELPER METHODS
extension CSPushManager {
    func sendAuthTokenToApi(tokenString: String, completion: SendTokenToApiCompletion) {
        
    }
}

// MARK: - DELEGATE METHODS
extension CSPushManager: UNUserNotificationCenterDelegate {
    
}



/*
 SHARE IMAGE
 
 {
 "aps": {
 "alert": "Hello!",
 "sound": "default",
 "mutable-content": 1,
 "category" : "share_image",
 "badge": 1
 },
 "attachment-url": "https://media2.giphy.com/avatars/100soft/WahNEDdlGjRZ.gif"
 }
 
 
 SHARE VIDEO
 
 
 
 {
 "aps": {
 "alert": "Hello!",
 "sound": "default",
 "mutable-content": 1,
 "category" : "share_video",
 "badge": 1
 },
 "attachment-url": "https://youtu.be/x3bfa3DZ8JM"
 }
 
 */


