import UIKit

protocol Alertable {}
extension Alertable where Self: UIViewController {
    
    func showAlert(
        title: String = "",
        message: String,
        preferredStyle: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil,
        alertActionTitle: String = "OK",
        alertActionHanler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: alertActionTitle,
            style: UIAlertAction.Style.default,
            handler: alertActionHanler
        ))
        self.present(alert, animated: true, completion: completion)
    }
}

class AlertDialog: Alertable {
    class func showAlert(
        title: String = "",
        message: String,
        preferredStyle: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil,
        alertActionTitle: String = "OK",
        alertActionHanler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: alertActionTitle,
            style: UIAlertAction.Style.default,
            handler: alertActionHanler
        ))
        UIApplication.topViewController()!.present(alert, animated: true, completion: completion)
    }
}
