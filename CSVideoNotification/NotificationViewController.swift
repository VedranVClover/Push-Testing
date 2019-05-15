//
//  NotificationViewController.swift
//  CSVideoNotification
//
//  Created by Vedran on 13/05/2019.
//  Copyright © 2019 Vedran. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

import RxCocoa
import RxSwift

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
    @IBOutlet weak var playPausebutton: AnimatablePlayButton!
    
    var viewModel: NotificationViewModel!
    
    let bag = DisposeBag()
    
//    var videoPlayer: AVPlayer?
//    var playerItem: AVPlayerItem?
//    var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = NotificationViewModel()
        // Loading Spinner
        viewModel
            .loading
        .bind(to: progressSpinner.rx.isAnimating)
        .disposed(by: bag)
        
        // View size bouned to Video size
        viewModel
        .videoRatio
        .subscribe(onNext: { [unowned self] ratio in
            let width = self.view.bounds.size.width
            self.preferredContentSize = CGSize(width: width, height: width * ratio)
        })
        .disposed(by: bag)
        
        // On Touch listener
        let recog = UITapGestureRecognizer(target: self, action: #selector(onTouch))
        self.view.addGestureRecognizer(recog)
    }
    
    @objc func onTouch() {
        viewModel.onTouch.on(.next(Void()))
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let urlString = notification.request.content.userInfo["attachment-url"] as? String,
            let url = URL(string: urlString) else {
                return
        }
        
        viewModel.start(withUrl: url, parentLayer: self.playerContainer.layer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.onBoundsChanged.on(.next(self.view.bounds))
        
        playPausebutton
            .onFrameChanged
            .on(.next(playPausebutton.bounds))
        
        viewModel
            .playerIsPlaying
            .map{ $0 ? AnimatablePlayButton.ButtonState.pause : AnimatablePlayButton.ButtonState.play }
            .bind(to: playPausebutton.changeState)
            .disposed(by: bag)
    }

}


