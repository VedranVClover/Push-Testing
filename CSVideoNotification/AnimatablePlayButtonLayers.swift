//
//  AnimatablePlayButtonLayers.swift
//  CSVideoNotification
//
//  Created by Vedran on 15/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UIKit
import RxSwift

class CircleOrLeftBar: CAShapeLayer {
    var rect: CGRect!
    
    var recalculateListener: BehaviorSubject<(CGRect, AnimatablePlayButton.ButtonState)>!
    
    let bag = DisposeBag()
    
    required init(withinRect rect: CGRect, color: UIColor) {
        self.rect = rect
        super.init()
        self.strokeColor = color.cgColor
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 4.0
        self.backgroundColor = UIColor.clear.cgColor
        self.lineJoin = .round
        
        recalculateListener = BehaviorSubject(value: (rect, .play))
        
        recalculateListener
            .skip(1)
            .subscribe(onNext: { [weak self] (rect, state) in
                self?.isHidden = false
                self?.drawShapes(withRect: rect, isPaused: state == .pause)
            })
            .disposed(by: bag)
    }
    
    func drawShapes(withRect rect: CGRect, isPaused: Bool) {
        self.rect = rect
        let path = isPaused ? pauseLeftPath : circlePath
        self.path = path.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var pauseLeftPath: UIBezierPath {
        let barWidth:CGFloat = rect.width * 0.1
        let barHeight:CGFloat = rect.height * 0.5
        let barOriginX: CGFloat = rect.origin.x + rect.width / 2 - barWidth - 8.0
        let barOriginY: CGFloat = rect.origin.y + rect.height / 2 - barHeight / 2
        let path = UIBezierPath(rect: CGRect(x: barOriginX, y: barOriginY, width: barWidth, height: barHeight))
        return path
    }
    
    var circlePath: UIBezierPath {
        let ovalPath = UIBezierPath(ovalIn: rect)
        return ovalPath
    }
}

class TriangleOrRightBar: CAShapeLayer {
    var rect: CGRect!
    
    var recalculateListener: BehaviorSubject<(CGRect, AnimatablePlayButton.ButtonState)>!
    let bag = DisposeBag()
    
    required init(withinRect rect: CGRect, color: UIColor) {
        self.rect = rect
        super.init()
        self.strokeColor = color.cgColor
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 4.0
        self.backgroundColor = UIColor.clear.cgColor
        self.lineJoin = .round
        
        recalculateListener = BehaviorSubject(value: (rect, .play))
        
        recalculateListener
            .skip(1)
            .subscribe(onNext: { [weak self] (rect, state) in
                self?.drawShapes(withRect: rect, isPaused: state == .pause)
            })
            .disposed(by: bag)
    }
    
    func drawShapes(withRect rect: CGRect, isPaused: Bool) {
        self.rect = rect
        let path = isPaused ? pauseRightPath : trianglePath
        self.path = path.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var trianglePath: UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: rect.minX + 0.28000 * rect.width, y: rect.minY + 0.80000 * rect.height))
        bezierPath.addLine(to: CGPoint(x: rect.minX + 0.28000 * rect.width, y: rect.minY + 0.20000 * rect.height))
        bezierPath.addLine(to: CGPoint(x: rect.minX + 0.90000 * rect.width, y: rect.minY + 0.52000 * rect.height))
        bezierPath.addLine(to: CGPoint(x: rect.minX + 0.28000 * rect.width, y: rect.minY + 0.80000 * rect.height))
        
        bezierPath.close()
        return bezierPath
    }
    
    
    
    var pauseRightPath: UIBezierPath {
        let barWidth:CGFloat = rect.width * 0.1
        let barHeight:CGFloat = rect.height * 0.5
        let barOriginX: CGFloat = rect.origin.x + rect.width / 2 + barWidth - 4.0
        let barOriginY: CGFloat = rect.origin.y + rect.height / 2 - barHeight / 2
        let path = UIBezierPath(rect: CGRect(x: barOriginX, y: barOriginY, width: barWidth, height: barHeight))
        return path
    }
}

