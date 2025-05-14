//
//  HomeView.swift
//  MovieApp
//
//  Created by Rikkei on 14/05/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                Section {
                    ScrollView(.horizontal) {
                        HStack {
                            Spacer()
                                .frame(width: 20)
                            ForEach(viewModel.newestMovies, id: \.id) { movie in
                                MovieVerticalListItem(movie: movie)
                            }
                        }
                    }
                    
                } header: {
                    HomeMovieHeader(title: "Now Showing") {
                    }
                }
                
                Spacer()
                    .frame(height: 20)
                
                Section {
                    ForEach(viewModel.popularMovies, id: \.id) { movie in
                        MovieHorizontalListItem(movie: movie)
                    }
                } header: {
                    HomeMovieHeader(title: "Popular") {
                        
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("FilmKu")
    }
}

#Preview {
    HomeView()
}
