//
//  HomeMovieHeader.swift
//  MovieApp
//
//  Created by Rikkei on 14/05/2025.
//

import SwiftUI

struct HomeMovieHeader: View {
    var title: String
    var action : () -> Void
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .foregroundStyle(Color(.appDarkPuple))
            Spacer()
            Button("See more", action: action)
                .buttonStyle(SmallOutlineStyle())
        }
        .padding(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
        .background(.ultraThinMaterial)
    }
}

