//
//  AnimatablePlayButton.swift
//  CSVideoNotification
//
//  Created by Vedran on 14/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UIKit

class AnimatablePlayButton: UIView {
    
    let radius: CGFloat = 50.0
    let background = UIColor.lightGray.withAlphaComponent(0.7)
    let strokeColor = UIColor.blue
    
    var circleLeftBar: CircleOrLeftBar!
    var triangleRightBar: TriangleOrRightBar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    var insetedRectangle: CGRect {
        let ownSize = self.bounds.size
        return self.bounds.insetBy(dx: ownSize.width / 2 - radius, dy: ownSize.height / 2 - radius)
    }
    
}


extension AnimatablePlayButton {
    private func setupView() {
        self.backgroundColor = background
        
        self.circleLeftBar = CircleOrLeftBar(withinRect: insetedRectangle, color: strokeColor)
        self.circleLeftBar.frame = self.bounds
        self.layer.addSublayer(circleLeftBar)
        
        self.triangleRightBar = TriangleOrRightBar(withinRect: insetedRectangle, color: strokeColor)
        self.triangleRightBar.frame = self.bounds
        self.layer.addSublayer(triangleRightBar)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleLeftBar.drawShapes(withRect: self.insetedRectangle)
        triangleRightBar.drawShapes(withRect: self.insetedRectangle)
    }
}


extension AnimatablePlayButton {
    class CircleOrLeftBar: CAShapeLayer {
        var rect: CGRect!
        
        var isPaused = false {
            didSet {
                self.drawShapes(withRect: rect)
            }
        }
        
        required init(withinRect rect: CGRect, color: UIColor) {
            self.rect = rect
            super.init()
            self.strokeColor = color.cgColor
            self.fillColor = UIColor.clear.cgColor
            self.lineWidth = 4.0
            self.backgroundColor = UIColor.clear.cgColor
            drawShapes(withRect: rect)
        }
        
        func drawShapes(withRect rect: CGRect) {
            self.rect = rect
            let path = isPaused ? pauseLeftPath : circlePath
            self.path = path.cgPath
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        var pauseLeftPath: UIBezierPath {
            let path = UIBezierPath(rect: CGRect(x: rect.origin.x + 17,
                                                 y: rect.origin.y + 5,
                                                 width: 3,
                                                 height: 39))
            path.lineJoinStyle = .round
            return path
        }
        
        var circlePath: UIBezierPath {
            let ovalPath = UIBezierPath(ovalIn: rect)
            return ovalPath
        }
    }
    
    class TriangleOrRightBar: CAShapeLayer {
        var rect: CGRect!
        
        var isPaused = false {
            didSet {
                self.drawShapes(withRect: rect)
            }
        }
        
        required init(withinRect rect: CGRect, color: UIColor) {
            self.rect = rect
            super.init()
            self.strokeColor = color.cgColor
            self.fillColor = UIColor.clear.cgColor
            self.lineWidth = 4.0
            self.backgroundColor = UIColor.clear.cgColor
            self.lineJoin = .round
            drawShapes(withRect: rect)
        }
        
        func drawShapes(withRect rect: CGRect) {
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
            let path = UIBezierPath(rect: CGRect(x: rect.origin.x + 29,
                                                 y: rect.origin.y + 5,
                                                 width: 3,
                                                 height: 39))
            return path
        }
    }
    
}





