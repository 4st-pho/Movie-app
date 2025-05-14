//
//  MovieHorizontalListItem.swift
//  MovieApp
//
//  Created by Rikkei on 14/05/2025.
//

import SwiftUI

struct MovieHorizontalListItem: View {
    var movie: Movie
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            AsyncImage(url: URL(string: movie.imageUrl))
                .frame(width: 100, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Spacer()
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(movie.name)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                HStack {
                    Image("Star")
                    Text(movie.rating)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                
                FlowLayout(mode: .scrollable, items: movie.categories){ category in
                    Text(category)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.appLightPurple))
                        .padding(EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12))
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color(.appLightPurpleAccent)))
                }
                
                HStack {
                    Image("Clock")
                    Text(movie.duration)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
            }
        }
        .frame(alignment: .leading)
        .padding(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
    }
}


