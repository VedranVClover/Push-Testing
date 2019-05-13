//
//  NotificationViewModel.swift
//  CSVideoNotification
//
//  Created by Vedran on 13/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import AVFoundation

class NotificationViewModel {
    
    let bag = DisposeBag()
    
    let loading: BehaviorSubject<Bool> = BehaviorSubject(value: true)
    
    let onTouch: PublishSubject<Void> = PublishSubject.init()
    
    let onBoundsChanged: PublishSubject<CGRect> = PublishSubject.init()
    
    let videoRatio: PublishSubject<CGFloat> = PublishSubject.init()
    
    var videoPlayer: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    
    var playerIsPlaying: BehaviorSubject<Bool> = BehaviorSubject(value: true)
    
    init() {
        onTouch
            .withLatestFrom(playerIsPlaying)
            .map { !$0 }
            .bind(to: playerIsPlaying)
            .disposed(by: bag)
    }
    
}


extension NotificationViewModel {
    
    func start(withUrl url: URL, parentLayer: CALayer) {
        loading.onNext(true)
        
        let asset = AVAsset(url: url)
        if let track = asset.tracks(withMediaType: .video).first {
            let size = track.naturalSize
            let aspectRatio = size.height / size.width
            videoRatio.on(.next(aspectRatio))
        }
        
        playerItem = AVPlayerItem(asset: asset)
        self.videoPlayer = AVPlayer(playerItem: playerItem)
        self.playerLayer = AVPlayerLayer(player: videoPlayer!)
        parentLayer.addSublayer(playerLayer!)
        playerLayer?.frame = parentLayer.bounds
        
        onBoundsChanged
            .subscribe(onNext: { [weak self] newFrame in
                self?.playerLayer?.frame = newFrame
            })
            .disposed(by: bag)
        
        let playerStatus = videoPlayer!
            .rx
            .observe(AVPlayer.Status.self, "status")
            .map{ $0 == .readyToPlay }
            .asObservable()
            .debug("Player Status Observer", trimOutput: true)
            .share()
        
        playerStatus
            .bind(to: loading)
            .disposed(by: bag)
        
        Observable.combineLatest(playerStatus, playerIsPlaying) { videoReady, shouldPlay in
            return videoReady && shouldPlay
            }
            .subscribe(onNext: { [weak self] shouldPlay in
                if shouldPlay {
                    self?.videoPlayer?.play()
                } else {
                    self?.videoPlayer?.pause()
                }
            })
            .disposed(by: bag)
    }
    
    
}


