//
//  MovieVerticalListItem.swift
//  MovieApp
//
//  Created by Rikkei on 14/05/2025.
//

import SwiftUI

struct MovieVerticalListItem: View {
    var movie: Movie
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: movie.imageUrl))
                .scaledToFit()
                .frame(width: 150, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(movie.name)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .lineLimit(1)
            HStack {
                Image("Star")
                Text(movie.rating)
                    .font(.system(size: 10))
                    .fontWeight(.light)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
        }
        .frame(width: 150)
    }
}

