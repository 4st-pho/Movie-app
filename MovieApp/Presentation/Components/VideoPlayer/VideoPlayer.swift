import UIKit
import AVKit
class VideoPlayer: UIView {
    
    // MARK: Outlets
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var playbackControlsViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var loaderView: UIImageView!
    
    // MARK: - Variables
    private var timeControlStatus = "timeControlStatus"
    private var avPlayer: AVPlayer?
    let playerViewController = AVPlayerViewController()
    private let rewindForwardDuration: Float64 = 10
    
    public var isMuted = true {
        didSet {
            self.avPlayer?.isMuted = self.isMuted
            self.volumeButton.isSelected = self.isMuted
        }
    }
    
    public var isToShowPlaybackControls = true {
        didSet {
            if !isToShowPlaybackControls {
                self.playbackControlsViewHeightContraint.constant = 0.0
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override public func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == timeControlStatus,
           let change = change,
           let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
           let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int
        {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.loaderView.isHidden = true
                    } else {
                        self?.loaderView.isHidden = false
                    }
                }
            }
        }
    }
    
    deinit {
        avPlayer?.removeObserver(self, forKeyPath: timeControlStatus)
        NotificationCenter.default.removeObserver(self)
        avPlayer?.pause()
        VideoPlayerController.shared.controller?.player?.play()
        print("Deinit")
    }
    
    // MARK: - UI Setup
    private func setupUI(){
        setupLoaderView()
    }
    
    private func setupLoaderView() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = .pi * 2.0 * 2 * 60.0
        rotationAnimation.duration = 200.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.infinity
        loaderView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    // MARK: Public Methods
    
    
    
//    public func loadVideo(with movie: Movie) {
//        guard let url = URL(string: movie.videoLink) else {return}
//        avPlayer = initAvPlayer(with: url)
//        guard let avPlayer = avPlayer else { return }
//        let avPlayerLayer = initPlayerLayer(with: avPlayer)
//        self.videoView.layer.addSublayer(avPlayerLayer)
//        VideoPlayerController.shared.setMovie(movie)
//        VideoPlayerController.shared.setAvPlayer(avPlayer)
//    }
    
    public func loadVideo(with url: URL) {
        avPlayer = initAvPlayer(with: url)
        guard let avPlayer = avPlayer else { return }
        let avPlayerLayer = initPlayerLayer(with: avPlayer)
        self.videoView.layer.addSublayer(avPlayerLayer)
    }
    
    public func loadVideoWithPlayer(_ player: AVPlayer) {
        avPlayer = player
        guard let avPlayer = avPlayer else { return }
        registerAvPlayerNoti(avPlayer)
        let avPlayerLayer = initPlayerLayer(with: avPlayer)
        self.videoView.layer.addSublayer(avPlayerLayer)
    }
    
    public func playVideo() {
        avPlayer?.play()
        playPauseButton.isSelected = true
    }
    
    public func pauseVideo() {
        self.avPlayer?.pause()
        self.playPauseButton.isSelected = false
    }
    
    // MARK: Actions
    @IBAction private func onTapPlayPauseVideoButton(_ sender: UIButton) {
        if sender.isSelected {
            self.pauseVideo()
        } else {
            self.playVideo()
        }
    }
    
    @IBAction private func onTapExpandVideoButton(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerDidDismiss), name: Notification.Name("avPlayerDidDismiss"), object: nil)
        guard let player = avPlayer else { return }
        playerViewController.player = player
        VideoPlayerController.shared.controller = playerViewController
        self.parentViewController()?.present(playerViewController, animated: true)
    }
    
    @IBAction private func onTapVolumeButton(_ sender: UIButton) {
        self.isMuted = !sender.isSelected
    }
    
    @IBAction private func onTapRewindButton(_ sender: UIButton) {
        if let currentTime = self.avPlayer?.currentTime() {
            var newTime = CMTimeGetSeconds(currentTime) - rewindForwardDuration
            if newTime <= 0 {
                newTime = 0
            }
            self.avPlayer?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    @IBAction private func onTapForwardButton(_ sender: UIButton) {
        if let currentTime = self.avPlayer?.currentTime(), let duration = self.avPlayer?.currentItem?.duration {
            var newTime = CMTimeGetSeconds(currentTime) + rewindForwardDuration
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            self.avPlayer?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
}

// MARK: - Private Methods
private extension VideoPlayer {
    func initAvPlayer(with url: URL) -> AVPlayer {
        let avPlayer = AVPlayer(url: url)
        registerAvPlayerNoti(avPlayer)
        return avPlayer
    }
    
    func registerAvPlayerNoti(_ avPlayer: AVPlayer){
        avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
            if let duration = avPlayer.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                let seconds = CMTimeGetSeconds(progressTime)
                let progress = Float(seconds/durationSeconds)
                
                DispatchQueue.main.async {
                    self?.progressBar.progress = progress
                    if progress >= 1.0 {
                        self?.progressBar.progress = 0.0
                    }
                }
            }
        }
        avPlayer.addObserver(self, forKeyPath: timeControlStatus, options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
    }
    
    func initPlayerLayer(with player: AVPlayer) -> AVPlayerLayer {
        self.layoutIfNeeded()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.contentsGravity = .resizeAspectFill
        return playerLayer
    }
    
    // MARK: - Selectors
    @objc func avPlayerDidDismiss(_ notification: Notification) {
        let isPlaying = ( notification.userInfo?["isPlaying"] as? Bool) ?? false
        let isMute = ( notification.userInfo?["isMute"] as? Bool) ?? true
        
        DispatchQueue.main.async() {[weak self] in
            self?.isMuted = isMute
            if isPlaying {
                self?.playVideo()
            } else {
                self?.pauseVideo()
            }
            print("\n\n\n remove  avPlayerDidDismiss \n\n\n")
        }
    }
    
    @objc func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            guard let self  = self else { return }
            guard let playerItem = notification.object as? AVPlayerItem else { return }
            playerItem.seek(to: .zero, completionHandler: nil)
            pauseVideo()
            
        }
    }
}



// MARK: - AV Player View Delegate

extension AVPlayerViewController {
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let userInfo : [AnyHashable : Any] =
        [
            "isPlaying": self.player?.timeControlStatus != .paused,
            "isMute": self.player?.isMuted ?? false
        ]
        print(userInfo)
        NotificationCenter.default.post(name: Notification.Name("avPlayerDidDismiss"), object: nil, userInfo: userInfo)
        print("NotificationCenter.default.post(name: Notification.Name), object: nil, userInfo: userInfo)")
    }
}

