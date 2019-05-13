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
    
    public let unreadChats:BehaviorSubject<[CSChat]> = BehaviorSubject(value: [])
    
    let newUnreadChat:PublishSubject<CSChat> = PublishSubject.init()
    let seenChat:PublishSubject<CSChat> = PublishSubject.init()
    
    let bag = DisposeBag()
    
    
    // MARK: - INITIALIZATION
    
    override init() {
        super.init()
        
        newUnreadChat
        .asObservable()
            .withLatestFrom(unreadChats.asObservable()) { newChat, allChatIds -> [CSChat] in
                var mutableChats = allChatIds.filter{ $0 != newChat }
                mutableChats.append(newChat)
                return mutableChats
        }
        .bind(to: unreadChats)
        .disposed(by: bag)
        
        seenChat
        .asObserver()
            .withLatestFrom(unreadChats.asObservable()) { seenChatId, allChatIds -> [CSChat] in
                return allChatIds.filter{ $0 != seenChatId }
        }
        .bind(to: unreadChats)
        .disposed(by: bag)
        
        newUnreadChat
            .debug("New Unread Chat Observable:", trimOutput: true)
            .subscribe()
            .disposed(by: bag)
        
        seenChat
            .debug("Seen Chat Observable:", trimOutput: true)
            .subscribe()
            .disposed(by: bag)
        
        unreadChats
            .map { $0.reduce(0, { result, chat in
                result + chat.badgeNumber
            })}
            .debug("Unread Chats Count Observable", trimOutput: true)
            .subscribe(onNext: { numberOfChats in
                UIApplication.shared.applicationIconBadgeNumber = numberOfChats
            })
        .disposed(by: bag)
    }
    
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
        return UNNotificationCategory(identifier: CSPushConstants.PushCategory.txtMessageCategory.rawValue,
                                      actions: [replyAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    var videoShareCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: CSPushConstants.PushCategory.shareVideo.rawValue,
                                      actions: [replyAction, viewInAppAction, dismissAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    var imageShareCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: CSPushConstants.PushCategory.shareImage.rawValue,
                                      actions: [replyAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    var urlShareCategory: UNNotificationCategory {
        return UNNotificationCategory(identifier: CSPushConstants.PushCategory.shareUrl.rawValue,
                                      actions: [replyAction],
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
    
    
    
    // MARK: - HANDLING PUSH BADGE NUMBER
    
    func didReceivePushNotification(withUserInfo userInfo: [AnyHashable : Any]) {
        guard let chatId = userInfo[CSPushConstants.chatId] as? String,
            let contacts = userInfo[CSPushConstants.groupContacts] as? [String],
            let apps = userInfo["aps"] as? [String : Any],
            let budgeNumber = apps["badge"] as? Int else { return }
        self.newUnreadChat.on(.next(CSChat(chatId: chatId, contacts: contacts, badgeNumber: budgeNumber)))
    }
    
    func chatSeen(chatId: String, contactName: String) {
        self.seenChat.on(.next(CSChat(chatId: chatId, contacts: [contactName])))
    }
    
    func dismissAllBadges() {
        self.unreadChats.on(.next([]))
    }
}

// MARK: - HELPER METHODS
extension CSPushManager {
    func sendAuthTokenToApi(tokenString: String, completion: SendTokenToApiCompletion) {
        
    }
}

// MARK: - DELEGATE METHODS
extension CSPushManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        /*
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        let category = notification.request.content.categoryIdentifier
        
        completionHandler()*/
    }
}



/*
 SHARE VIDEO
 
 {
 "aps": {
 "alert": "Check out this Video",
 "sound": "default",
 "mutable-content": 1,
 "category" : "share_video",
 "badge": 1,
 "content-available" : 1
 },
 "group_contacts" : ["Jura"],
 "attachment-url": "https://youtu.be/x3bfa3DZ8JM",
 "chat_id" : "1ur4"
 }
 
 
 WRITE MESSAGE
 
 {
 "aps": {
 "alert": "Hey what's up Dude?",
 "sound": "default",
 "mutable-content": 1,
 "category" : "txt_message",
 "badge": 3,
 "content-available" : 1
 },
 "group_contacts" : ["Sinisa"],
 "chat_id" : "51n154"
 }
 
 
 SHARE URL
 
 {
 "aps": {
 "alert": "Check out this Link!",
 "sound": "default",
 "mutable-content": 1,
 "category" : "share_url",
 "badge": 1,
 "content-available" : 1
 },
 "group_contacts" : ["Jura"],
 "shared_url" : "https://www.amazon.de/",
 "chat_id" : "1ur4"
 }
 
 
 SHARE IMAGE
 
 {
 "aps": {
 "alert": "Check out this Gif",
 "sound": "default",
 "mutable-content": 1,
 "category" : "share_image",
 "badge": 2,
 "content-available" : 1
 },
 "group_contacts" : ["Ivo"],
 "attachment-url": "https://media2.giphy.com/avatars/100soft/WahNEDdlGjRZ.gif",
 "chat_id" : "1v0"
 }
 
 
 */


