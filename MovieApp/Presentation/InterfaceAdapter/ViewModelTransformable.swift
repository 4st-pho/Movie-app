//
//  ViewModelTransformable.swift
//  MovieApp
//
//  Created by Rikkei on 15/04/2025.
//

import Foundation
import RxSwift

protocol ViewModelTransformable {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
