//
//  ViewController.swift
//  Push Testing
//
//  Created by Vedran on 29/04/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let contacts:Variable<[CSChat]> = Variable([])
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CSPushManager
            .instance
            .unreadChats
            .asObservable()
            .withLatestFrom(contacts.asObservable()) { unreadChats, allChats -> [CSChat] in
                var allChatsMutable = allChats
                let newChats = unreadChats.filter { !allChats.contains($0) }
                allChatsMutable += newChats
                    
                return allChatsMutable.map { inChat -> CSChat in
                    guard let newChat = (unreadChats.filter { $0 == inChat }).first else {
                        return CSChat(chatId: inChat.chatId, contacts: inChat.contacts)
                    }
                    return newChat
                }
            }
            .bind(to: contacts)
            .disposed(by: bag)
        
        
        let cellName = String(describing: MockChatCell.self)
        let nib = UINib(nibName: cellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellName)
        
        contacts
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: cellName, cellType: MockChatCell.self), curriedArgument: { (row, model, cell) in
                cell.setGroupNames(names: model.contacts)
                cell.numberOfUnseenMessages(nuberOfMessages: model.badgeNumber)
            })
        .disposed(by: bag)
        
        tableView
            .rx
            .itemSelected
            .withLatestFrom(self.contacts.asObservable(), resultSelector: { indexPath, chats in
                chats[indexPath.row]
            })
            .bind(to: CSPushManager.instance.seenChat)
            .disposed(by: bag)
    }


}


