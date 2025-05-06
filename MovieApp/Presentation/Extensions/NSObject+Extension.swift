//
//  NSObject+Extension.swift
//  MovieApp
//
//  Created by MACBOOK PRO on 3/5/25.
//

import Foundation

protocol ScopeFunc { }

public extension NSObject {
    class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }

    var className: String {
        return String(describing: type(of: self))
    }
}

extension ScopeFunc {
    @inline(__always) func apply(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }

    @discardableResult
    @inline(__always) func letIt<R>(_ block: (Self) -> R) -> R {
        return block(self)
    }
}

protocol Weakifiable: AnyObject { }

extension Weakifiable {
    // that's used in closure
    func weakify(_ code: @escaping (Self) -> Void) -> () -> Void {
        return { [weak self] in
            guard let self = self else { return }
            code(self)
        }
    }

    // that's used in closure subscrible in Rxswift
    func weakify<T>(_ code: @escaping (T, Self) -> Void) -> (T) -> Void {
        return { [weak self] arg in
            guard let self = self else { return }
            code(arg, self)
        }
    }
}

/*
 this func will take all cofigure to chain function that use to configure this `Self`
 example :
 let label = UILabel()
     .with(\.textColor, setTo: .red)
     .with(\.text, setTo: "Foo")
     .with(\.textAlignment, setTo: .right)
     .with(\.layer.cornerRadius, setTo: 5)
 it's similar to SwiftUI and help us easily readable in coding
 */

protocol With {}

extension With where Self: AnyObject {
    @discardableResult
    func with<T>(_ property: ReferenceWritableKeyPath<Self, T>, setTo value: T) -> Self {
        self[keyPath: property] = value
        return self
    }
}

extension NSObject: ScopeFunc { }

extension NSObject: Weakifiable { }

extension NSObject: With { }

