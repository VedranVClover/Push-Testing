//
//  CSChat.swift
//  Push Testing
//
//  Created by Vedran on 09/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import Foundation

class CSChat {
    let chatId: String
    let contacts: [String]
    let badgeNumber: Int
    
    init(chatId: String, contacts: [String], badgeNumber: Int = 0) {
        self.chatId = chatId
        self.contacts = contacts
        self.badgeNumber = badgeNumber
//        super.init()
    }
}

extension CSChat: Equatable {
    static func == (lhs: CSChat, rhs: CSChat) -> Bool {
        return lhs.chatId == rhs.chatId
    }
}

