import Foundation

final class AppConfiguration {
    static private var token: String = UserDefaults.standard.string(forKey: "TokenCache") ?? ""
    static var apiBaseURL: String = getSecretKey("APIBaseURL")
    
    static private func getSecretKey(_ keyName: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "SecretKey", ofType: "plist") else {
            fatalError("Couldn't find file 'SecretKey.plist'.")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: keyName) as? String else {
            fatalError("Couldn't find key '\(keyName)' in 'SecretKey'.")
        }
        return value;
    }
    
    static func setCurrentToken(_ token: String){
        self.token = token
    }
    static func getCurrentToken() -> String {
        return token
    }
}
