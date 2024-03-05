import Foundation
import UIKit

class Utils{
    static func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static private let skipOnboardingkey = "skipOnboardingKey";
    
    static func isSkipOnboarding() -> Bool{
        return UserDefaults.standard.bool(forKey: skipOnboardingkey)
    }
    
    static func skipOnboarding(){
        UserDefaults.standard.set(true, forKey: skipOnboardingkey)
    }
    
    static func resetRootView(){
        DispatchQueue.main.async {
            
            guard let window = getKeyWindow() else {
                return
            }
            let mainTapBarController = MainTabBarController()
            window.rootViewController = mainTapBarController
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            let duration: TimeInterval = 0.2
            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:nil)
        }
    }
    
    static func localizedDescription(for error: Error) -> String {
        if let apiError = error as? APIError {
            if apiError.code == 401 {
                resetRootView()
            }
            return apiError.localizedDescription
        }
        return error.localizedDescription
    }
}
