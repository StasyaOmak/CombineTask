//
//  GuessTheNumberView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import SwiftUI
import Combine

struct GuessTheNumberView: View {
    
    @StateObject private var guessTheNumberViewModel = GuessTheNumberViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Загаданное число:")
                    .font(.title3)
                Text(String(guessTheNumberViewModel.numberToGuess.value))
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.black)
                    .opacity(guessTheNumberViewModel.isShowNumber ? 1.0 : 0.0)
            }
            .padding()
            TextField("Введите ваше число", text: $guessTheNumberViewModel.textFieldLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .foregroundColor(.black)
                .padding()
            Text(guessTheNumberViewModel.showMessage)
                .font(.title)
            Spacer()
            Button {
                guessTheNumberViewModel.endGame()
            } label: {
                Text("Завершить")
                    .foregroundColor(.black)
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.yellow)
                    .frame(width: 150, height: 50)
            )
            Spacer()
        }
    }
}

#Preview {
    GuessTheNumberView()
}
