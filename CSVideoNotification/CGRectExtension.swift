//
//  CGRectExtension.swift
//  CSVideoNotification
//
//  Created by Vedran on 15/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UIKit

extension CGRect {
    
//    var insetedRectangle: CGRect {
//        let ownSize = self.bounds.size
        
//    }
    
    func insectRectBy(delta: CGFloat) -> CGRect {
        return self.insetBy(dx: self.width / 2 - delta, dy: self.height / 2 - delta)
    }
    
}

