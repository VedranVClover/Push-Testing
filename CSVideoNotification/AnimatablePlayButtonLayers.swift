//
//  AnimatablePlayButtonLayers.swift
//  CSVideoNotification
//
//  Created by Vedran on 15/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UIKit
import RxSwift

class CircleLayer: CAShapeLayer {
    
    var rect: CGRect!
    var isPaused = false
    
    public var recalculateListener: BehaviorSubject<(CGRect, AnimatablePlayButton.ButtonState)>!
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawShapes(withRect rect: CGRect, isPaused: Bool) {
        self.rect = rect
        let path = isPaused ? pauseModeShape : playModeShape
        animatePpathChange(newPath: path)
    }
    
    func animatePpathChange(newPath: UIBezierPath) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.2
        animation.fromValue = self.path
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.toValue = newPath.cgPath
        animation.fillMode = CAMediaTimingFillMode.both
        animation.isRemovedOnCompletion = false
        
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.path = newPath.cgPath
            self?.removeAllAnimations()
        }
        self.add(animation, forKey: nil)
        CATransaction.commit()
//        self.path = path.cgPath
    }
    
    var pauseModeShape: UIBezierPath {
        let barWidth:CGFloat = rect.width * 0.1
        let barHeight:CGFloat = rect.height * 0.5
        let barOriginX: CGFloat = rect.origin.x + rect.width / 2 - barWidth - 8.0
        let barOriginY: CGFloat = rect.origin.y + rect.height / 2 - barHeight / 2
        let path = UIBezierPath(rect: CGRect(x: barOriginX, y: barOriginY, width: barWidth, height: barHeight))
        return path
    }
    
    var playModeShape: UIBezierPath {
        let ovalPath = UIBezierPath(ovalIn: rect)
        return ovalPath
    }
    
}


class TriangleLayer: CircleLayer {
    override var playModeShape: UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: rect.minX + 0.28000 * rect.width, y: rect.minY + 0.80000 * rect.height))
        bezierPath.addLine(to: CGPoint(x: rect.minX + 0.28000 * rect.width, y: rect.minY + 0.20000 * rect.height))
        bezierPath.addLine(to: CGPoint(x: rect.minX + 0.90000 * rect.width, y: rect.minY + 0.52000 * rect.height))
        bezierPath.addLine(to: CGPoint(x: rect.minX + 0.28000 * rect.width, y: rect.minY + 0.80000 * rect.height))
        
        bezierPath.close()
        return bezierPath
    }
    
    override var pauseModeShape: UIBezierPath {
        let barWidth:CGFloat = rect.width * 0.1
        let barHeight:CGFloat = rect.height * 0.5
        let barOriginX: CGFloat = rect.origin.x + rect.width / 2 + barWidth - 4.0
        let barOriginY: CGFloat = rect.origin.y + rect.height / 2 - barHeight / 2
        let path = UIBezierPath(rect: CGRect(x: barOriginX, y: barOriginY, width: barWidth, height: barHeight))
        return path
    }
}

