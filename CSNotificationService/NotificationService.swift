//
//  NotificationService.swift
//  CSNotificationService
//
//  Created by Vedran on 06/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UserNotifications
import SDWebImage

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            //Share Image
            switch bestAttemptContent.categoryIdentifier {
            // MARK: - SHARE IMAGE HANDLER
            case CSPushConstants.PushCategory.shareImage.rawValue :
                guard let content = request.content.mutableCopy() as? UNMutableNotificationContent,
                    let attachmentUrlString = content.userInfo["attachment-url"] as? String,
                    let attachmentUrl = URL(string: attachmentUrlString) else {
                        contentHandler(bestAttemptContent)
                        break
                }
                let extensionName = attachmentUrl.pathExtension
                downloadWithURL(downloadUrl: attachmentUrl, filename: "image.\(extensionName)") { attachment in
                    if let attachment = attachment {
                        bestAttemptContent.attachments = [attachment]
                    }
                    bestAttemptContent.title = CSPushConstants
                        .PushCategory
                        .shareImage
                        .pushDescription(userName: content.userInfo[CSPushConstants.contactName] as? String)
                    contentHandler(bestAttemptContent)
                }
                
            // MARK: - SHARE VIDEO HANDLER
            case CSPushConstants.PushCategory.shareVideo.rawValue :
                guard let content = request.content.mutableCopy() as? UNMutableNotificationContent,
                    let attachmentUrlString = content.userInfo["attachment-url"] as? String,
                    let attachmentUrl = URL(string: attachmentUrlString) else {
                        contentHandler(bestAttemptContent)
                        break
                }
                let videoIdentifier = attachmentUrl.lastPathComponent
                guard let thumbnailUrl = URL(string: "https://img.youtube.com/vi/\(videoIdentifier)/0.jpg") else {
                    return contentHandler(bestAttemptContent)
                }
                downloadWithURL(downloadUrl: thumbnailUrl, filename: "image.jpg") { attachment in
                    if let attachment = attachment {
                        bestAttemptContent.attachments = [attachment]
                    }
                    bestAttemptContent.title = CSPushConstants
                        .PushCategory
                        .shareVideo
                        .pushDescription(userName: content.userInfo[CSPushConstants.contactName] as? String)
                    contentHandler(bestAttemptContent)
                }
               
            // MARK: - TEXT MESSAGE HANDLER
            case CSPushConstants.PushCategory.txtMessageCategory.rawValue :
                guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else {
                    contentHandler(bestAttemptContent)
                    break
                }
                bestAttemptContent.title = "\(CSPushConstants.PushCategory.txtMessageCategory.pushDescription(userName: content.userInfo[CSPushConstants.contactName] as? String)) \(bestAttemptContent.title)"
                contentHandler(bestAttemptContent)
                
            // MARK: - SHARE URL HANDLER
            case CSPushConstants.PushCategory.shareUrl.rawValue :
                guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else {
                    contentHandler(bestAttemptContent)
                    break
                }
                bestAttemptContent.title = "\(CSPushConstants.PushCategory.txtMessageCategory.pushDescription(userName: content.userInfo[CSPushConstants.contactName] as? String)) \(bestAttemptContent.title)"
                if let url = content.userInfo[CSPushConstants.sharedUrl] as? String,
                    !url.isEmpty {
                    bestAttemptContent.body = bestAttemptContent.body + " \(url)"
                }
                
                contentHandler(bestAttemptContent)
            default :
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func downloadWithURL(downloadUrl: URL, filename: String, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: downloadUrl) { [weak self] (url, response, error) in
            guard error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let attachment =  self?.create(imageFileIdentifier: filename, data: data, options: nil) else {
                    completion(nil)
                    return
            }
            completion(attachment)
        }
        task.resume()
    }
    
    func create(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
            
            try data.write(to: fileURL!, options: [])
            let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL!, options: options)
            return imageAttachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }

}
