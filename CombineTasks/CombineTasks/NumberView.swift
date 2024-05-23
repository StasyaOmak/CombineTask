//
//  ContentView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import SwiftUI
import Combine


struct NumberView: View {
    @StateObject private var viewModel = NumberViewModel()
    
    var body: some View {
            VStack {
                Spacer()
                VStack {
                    TextField("Введите число", text: $viewModel.textFieldInput.value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    HStack(spacing: 70) {
                        Button("Добавить") {
                            viewModel.addToList()
                        }
                        .tint(.green)
                        Button("Очистить список") {
                            viewModel.clearList()
                        }
                        .tint(.red)
                    }
                    .padding()
                    Text(viewModel.error?.rawValue ?? "")
                        .foregroundColor(.red)
                }
                List(viewModel.dataToView, id: \.self) { item in
                        Text(item)
                }
                .font(.title)
                
            }
        }
}

enum InvalidNumberInput: String, Error, Identifiable {
    var id: String { rawValue }
    case falseNumber = "Введенное значение не является\nчислом"
}

class NumberViewModel: ObservableObject {
    @Published var error: InvalidNumberInput?
    @Published var dataToView: [String] = []
    
        var textFieldInput = CurrentValueSubject<String, Never>("")
        var valueToAdd = CurrentValueSubject<String, Never>("")

        var datas: [String?] = []

        var cancellables: Set<AnyCancellable> = []
        
    init() {
        valueToAdd
            .dropFirst()
                .sink { [unowned self] newValue in
                    datas.append(newValue)
                    dataToView.removeAll()
                    fetch()
                }
                .store(in: &cancellables)
        }
    
    func addToList() {
        _ = validNumber(value: textFieldInput.value)
            .sink { [unowned self] completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                valueToAdd.value = value
            }
    }
    
    
    func validNumber(value: String) -> AnyPublisher<String, InvalidNumberInput> {
        if isNonNumeric(input: value) {
            return Fail(error: InvalidNumberInput.falseNumber)
                .eraseToAnyPublisher()
        } else {
            error = nil
            return Just(value)
                .setFailureType(to: InvalidNumberInput.self)
                .eraseToAnyPublisher()
        }
    }
    
    func isNonNumeric(input: String) -> Bool {
        if input.isEmpty || input == " " {
            return true
        }
        for char in input {
            if !char.isNumber {
                return true
            }
        }
        return false
    }
    
    func fetch() {
        _ = datas.publisher
            .flatMap { item -> AnyPublisher<String, Never> in
                if let item = item {
                    return Just(item)
                        .eraseToAnyPublisher()
                } else {
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
            }
            .sink { [unowned self] item in
                dataToView.append(item)
            }
    }
    
    func clearList() {
        datas.removeAll()
        dataToView.removeAll()
        error = nil
        textFieldInput.value = ""
    }
}

#Preview {
    NumberView()
}

