import Foundation
import AVKit

final class VideoPlayerController : NSObject{
    static let shared = VideoPlayerController()
    var keepAvPlayerPlaying = false
    
    var controller: AVPlayerViewController? = nil
    {
        didSet {
            controller?.delegate = self
        }
    }
    
    private override init() {
        super.init()
    }
}

extension VideoPlayerController : AVPlayerViewControllerDelegate {
    public func playerViewController(
        _ playerViewController: AVPlayerViewController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        let keyWindow = Utils.getKeyWindow()
        if let topViewController = keyWindow?.rootViewController, let playerViewController = self.controller {
            topViewController.present(playerViewController, animated: true, completion: nil)
        }
        print("\n restoreUserInterfaceForPictureInPictureStopWithCompletionHandler \n")
        completionHandler(true)
    }
    
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        controller = playerViewController
    }
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        controller = nil
    }
}
