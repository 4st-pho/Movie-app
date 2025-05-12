//
//  Navigation+.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import Foundation
import UIKit
import SwiftUI

extension UINavigationController {
    func pushView<V: View>(_ view: V, animated: Bool = true) {
        let vc = UIHostingController(rootView: view)
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: animated)
    }
}
