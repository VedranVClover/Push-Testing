//
//  MockChatCell.swift
//  Push Testing
//
//  Created by Vedran on 09/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UIKit

class MockChatCell: UITableViewCell {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var numberOfUnseenMessages: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setGroupNames(names: [String]) {
        contactName.text = names.joined(separator: ", ")
    }
    
    func numberOfUnseenMessages(nuberOfMessages: Int) {
        guard nuberOfMessages > 0 else {
            numberOfUnseenMessages.text = "0"
            numberOfUnseenMessages.isHidden = true
            self.backgroundColor = .clear
            return
        }
        numberOfUnseenMessages.text = "\(nuberOfMessages)"
        numberOfUnseenMessages.isHidden = false
        self.backgroundColor = .darkGray
    }
    
}
