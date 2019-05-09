//
//  CSPushConstants.swift
//  Push Testing
//
//  Created by Vedran on 06/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import Foundation

class CSPushConstants {
    
    enum PushCategory: String {
        case txtMessageCategory = "txt_message"
        case shareImage = "share_image"
        case shareUrl = "share_url"
        case shareVideo = "share_video"
        
        func pushDescription(userName: String?) -> String {
            var descr = "\(userName ?? "Contact") "
            switch self {
            case .shareImage:
                descr += "shared an Image"
            case .shareUrl:
                descr += "shared a Link"
            case .shareVideo:
                descr += "shared a Video"
            case .txtMessageCategory:
                descr += "wrote:"
            }
            return descr
        }
    }
    
    
    static let replyAction = "REPLY"
    static let viewAction = "VIEW"
    static let dismissAction = "DISMISS"
    static let openUrlAction = "OPEN_URL"
    
    static let contactName = "contact_name"
    static let sharedUrl = "shared_url"
    static let chatId = "chat_id"
    
}

