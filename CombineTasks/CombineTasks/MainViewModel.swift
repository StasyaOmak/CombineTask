//
//  MainViewModel.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 27/05/2024.
//

import Foundation

import Combine
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var state: ViewState<[Episode]> = .loading
    @Published var characterImages: [Image] = []
    @Published var characterNames: [String] = []
    @Published var errorForAlert: ErrorForAlert?
    
    var cancellables: Set<AnyCancellable> = []

    
    func fetchEpisodes() {
        guard let url = URL(string: "https://rickandmortyapi.com/api/episode") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Episodes.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    errorForAlert = ErrorForAlert(message: error.localizedDescription)
                    state = .error(error)
                }
            } receiveValue: { [unowned self] episodes in
                let results = episodes.results.filter { !$0.episode.contains("S02") }
                for result in results {
                    fetchCharacter(for: result)
                }
                state = .data(results)
            }
            .store(in: &cancellables)
    }
    
    func fetchCharacter(for episode: Episode) {
        let characterArrayMaxAmount = episode.characters.count
        let urlToRandomCharacter = episode.characters[Int.random(in: 0..<characterArrayMaxAmount)]
        
        guard let url = URL(string: urlToRandomCharacter) else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Character.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [unowned self] character in
                characterNames.append(character.name)
                let imageUrl = character.image
                fetchImage(url: imageUrl)
            }
            .store(in: &cancellables)
    }
    
    
    func fetchImage(url: String) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .tryMap { data in
                guard let uiImage = UIImage(data: data) else {
                    throw ErrorForAlert(message: "No image")
                }
                return Image(uiImage: uiImage)
            }
            .receive(on: DispatchQueue.main)
            .replaceError(with: Image("blank"))
            .sink { [unowned self] image in
                characterImages.append(image)
            }
            .store(in: &cancellables)
    }
    
}
