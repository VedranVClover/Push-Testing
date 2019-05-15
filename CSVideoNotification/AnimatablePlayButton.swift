//
//  AnimatablePlayButton.swift
//  CSVideoNotification
//
//  Created by Vedran on 14/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UIKit
import RxSwift

class AnimatablePlayButton: UIView {
    
    enum ButtonState {
        case play, pause
    }
    
    let radius: CGFloat = 50.0
    let background = UIColor.lightGray.withAlphaComponent(0.7)
    let strokeColor = UIColor(red: 2.0 / 255.0, green: 136 / 255.0, blue: 209 / 255.0, alpha: 1.0)
    
    let changeState: BehaviorSubject<ButtonState> = BehaviorSubject(value: .play)
    var onFrameChanged: BehaviorSubject<CGRect>!
    let bag = DisposeBag()
    
    var circleLeftBar: CircleOrLeftBar!
    var triangleRightBar: TriangleOrRightBar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView(withFrame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView(withFrame: self.bounds)
    }
    
    
    
}


extension AnimatablePlayButton {
    private func setupView(withFrame: CGRect) {
        self.backgroundColor = background
        
        self.onFrameChanged = BehaviorSubject(value: withFrame)
        
        self.circleLeftBar = CircleOrLeftBar(withinRect: withFrame, color: strokeColor)
        self.circleLeftBar.frame = self.bounds
        self.layer.addSublayer(circleLeftBar)
        
        self.triangleRightBar = TriangleOrRightBar(withinRect: withFrame, color: strokeColor)
        self.triangleRightBar.frame = self.bounds
        self.layer.addSublayer(triangleRightBar)
        
        
        let stateChangedObserver = Observable.combineLatest(onFrameChanged,
                                                            changeState) { [unowned self] frame, state in
                                                                return (frame.insectRectBy(delta: self.radius), state)
            }
            .debug("AnimatableButtonState", trimOutput: true)
            .distinctUntilChanged { $0.0 == $1.0 && $0.1 == $1.1 }
            .share()
        
        stateChangedObserver
            .bind(to: circleLeftBar.recalculateListener)
            .disposed(by: bag)
        
        stateChangedObserver
            .bind(to: triangleRightBar.recalculateListener)
            .disposed(by: bag)
    }
    
}


extension AnimatablePlayButton {
    
    
}





