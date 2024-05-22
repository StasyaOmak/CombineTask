//
//  GuessTheNumberViewModel.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import SwiftUI
import Combine

class GuessTheNumberViewModel: ObservableObject {
    
    @Published var showMessage = ""
    @Published var textFieldLabel = ""
    @Published var isShowNumber = false
    
    var numberToGuess = CurrentValueSubject<Int, Never>(Int.random(in: 0...100))
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        $textFieldLabel
            .dropFirst(2)
            .map { text -> Int in
                guard let guessedNumber = Int(text) else { return 0 }
                return guessedNumber
            }
            .delay(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [unowned self] guessedNumber in
                self.compareNumbers(guessedNumber)
                
            }
            .store(in: &cancellables)
    }
    
    func compareNumbers(_ guessedNumber: Int) {
        let actualNumber = numberToGuess.value
        if guessedNumber < actualNumber {
            showMessage = "Введенное число меньше загаданного"
        } else if guessedNumber > actualNumber {
            showMessage = "Введенное число больше загаданного"
        } else {
            showMessage = "Вы угадали!"
        }
    }
    
    func endGame() {
        cancellables.removeAll()
        isShowNumber = true
    }
}
