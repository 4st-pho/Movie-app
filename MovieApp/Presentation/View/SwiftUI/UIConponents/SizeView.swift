//
//  SizeBox.swift
//  MovieApp
//
//  Created by Rikkei on 12/05/2025.
//

import SwiftUI

struct SizeView: View {
    var width: CGFloat?
    var height: CGFloat?
    var body: some View {
        Spacer()
            .frame(width: width, height: height)
    }
}

