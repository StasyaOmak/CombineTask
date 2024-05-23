//
//  PrimeNumber.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import SwiftUI
import Combine

struct PrimeNumber: View {
    @StateObject var viewModel = PrimeNumberViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Введите число", text: $viewModel.textFieldText)
                .textFieldStyle(.roundedBorder)
                .padding()
            Button("Проверить простоту числа") {
                viewModel.check()
            }
            Spacer()
                .frame(height: 20)
            Text(viewModel.textToShow)
                .foregroundColor(.green)
            Spacer()
        }
    }
}

enum PrimeError: String, Error, Identifiable {
    var id: String { rawValue }
    case castingFailed = "Нельзя приобразовать String в Int"
}

class PrimeNumberViewModel: ObservableObject {
    @Published var textFieldText = ""
    @Published var textToShow = ""
    
    var cancellable: AnyCancellable?

    
    func checkPrimeNumber() -> AnyPublisher<Bool, PrimeError> {
        Deferred {
            Future { [unowned self] promise in
                guard let number = Int(self.textFieldText) else { promise(.failure(.castingFailed))
                    return
                }
                if isPrime(number) {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func check() {
        cancellable = checkPrimeNumber()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [unowned self] value in
                showDescription(isPrime: value)
            }
    }
    
    func isPrime(_ number: Int) -> Bool {
        if number < 2 {
            return false
        }
        for i in 2..<number {
            if number % i == 0 {
                return false
            }
        }
        return true
    }
    
    func showDescription(isPrime: Bool) {
        if isPrime {
            textToShow = "\(textFieldText) - простое число"
        } else {
            textToShow = "\(textFieldText) - не простое число"
        }
    }
    
    
}

#Preview {
    PrimeNumber()
}
