//
//  ServiceFacade.swift
//  MovieApp
//
//  Created by Rikkei on 14/04/2025.
//

import Foundation
import Swinject

final class AppDIContainer {
    private static var assembler: Assembler!
    private static let container = Container()
    private static let threadSafeContainer: Resolver = container.synchronize()
    
    static func registerModules() {
        assembler = Assembler([
            HardwareAssembly(),
            CoreAssembly(),
            ServicesAssembly()
        ], container: container)
    }
    
    static func resolve<T>(_ type: T.Type, name: String? = nil) -> T? {
        return threadSafeContainer.resolve(type, name: name)
    }
    
    static func resolve<T, Arg1>(
        _ type: T.Type,
        name: String?,
        argument: Arg1
    ) -> T? {
        return threadSafeContainer.resolve(type, name: name, argument: argument)
    }
    
    static func resolve<T, Arg1, Arg2>(
        _ type: T.Type,
        name: String?,
        arguments: Arg1, _ arg2: Arg2
    ) -> T? {
        return threadSafeContainer.resolve(type, name: name, arguments: arguments, arg2)
    }
    
    static func resolve<T, Arg1, Arg2, Arg3>(
        _ type: T.Type,
        name: String?,
        arguments: Arg1, _ arg2: Arg2, _ arg3: Arg3
    ) -> T? {
        return threadSafeContainer.resolve(type, name: name, arguments: arguments, arg2, arg3)
    }
    
    static func resolve<T, Arg1, Arg2, Arg3, Arg4>(
        _ type: T.Type,
        name: String?,
        arguments: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4
    ) -> T? {
        return threadSafeContainer.resolve(type, name: name, arguments: arguments, arg2, arg3, arg4)
    }
}
