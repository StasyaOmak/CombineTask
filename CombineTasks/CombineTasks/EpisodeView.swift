//
//  EpisodeView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 27/05/2024.
//

import SwiftUI


struct EpisodeView: View {
    
    private enum Constants {
        static let playIcon = "playIcon"
        static let heartIcon = "heart"
    }
    
    @EnvironmentObject var mainViewModel: MainViewModel
    var episodes: [Episode] = []
    
    var body: some View {
        LazyVStack(spacing: 55) {
            ForEach(episodes, id: \.name) { episode in
                VStack(alignment: .leading) {
                    if let index = episodes.firstIndex(where: { $0.name == episode.name }) {
                        if index < mainViewModel.characterImages.count && index < mainViewModel.characterNames.count {
                            mainViewModel.characterImages[index]
                                .resizable()
                                .frame(width: 311, height: 232)
                            Spacer()
                            Text(mainViewModel.characterNames[index])
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                        }
                    }
                    Spacer()
                    HStack {
                        Image(Constants.playIcon)
                        Text("\(episode.name) | ")
                        +
                        Text(episode.episode)
                        Spacer()
                        Image(Constants.heartIcon)
                    }
                    .padding(.horizontal)
                    .frame(width: 311, height: 71)
                    .background(.white)
                }
                .frame(width: 311, height: 357)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray, radius: 2.5, x: 0, y: 3)
                )
            }
        }
    }
}

#Preview {
    EpisodeView()
}
