//
//  MainView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 27/05/2024.
//

import SwiftUI
import Combine

struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                VStack {
                    Image("titleText")
                    Spacer()
                        .frame(height: 146)
                    Image("portal")
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                        .onAppear {
                            isAnimating = true
                        }
                    Spacer()
                }
            case .data(let episodes):
                ScrollView {
                    Image("titleText")
                        .padding(.bottom, 20)
                    EpisodeView(episodes: episodes)
                }
            case .error(_):
                EmptyView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                viewModel.fetchEpisodes()
            }
        }
        .alert(item: $viewModel.errorForAlert) { error in
            Alert(title: Text(error.title), message: Text(error.message), dismissButton: .default(Text("Try again"), action: {
                viewModel.fetchEpisodes()
            }))
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    MainView()
}
