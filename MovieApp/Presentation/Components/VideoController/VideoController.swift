import AVKit

//protocol VideoControllerDelegate{
//    func presentVideoController(_ aVPlayerViewController: AVPlayerViewController)
//}
class VideoController : NSObject{
    
    // MARK: - Variables

//    let delegate : VideoControllerDelegate?
//
//    private var player: AVPlayer = {
//        let videoUrl = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
//        let player = AVPlayer(url: videoUrl)
//        return player
//    }()
//
//    private lazy var playerController: AVPlayerViewController = {
//        let playerController = AVPlayerViewController()
//        playerController.delegate = self
//        playerController.player = player
//        playerController.allowsPictureInPicturePlayback = true
//        return playerController
//    }()
//
//    // MARK: - Lifecycle
//    override init() {
//
//    }
//
//    func presentVideoController() {
//        delegate?.presentVideoController(playerController)
//    }


    static func enableBackgroundMode() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback)
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
}
