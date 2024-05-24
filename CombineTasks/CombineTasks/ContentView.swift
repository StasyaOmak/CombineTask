//
//  FruitListView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import SwiftUI
import Combine

struct FruitListView: View {
    @StateObject var viewModel = FruitListViewModel()
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("")) {
                    List(viewModel.dataToView, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            HStack(spacing: 60) {
                Button("Добавить фрукт") {
                    viewModel.addFruit()
                }
                .tint(.green)
                Button("Удалить фрукт") {
                    viewModel.removeFruit()
                }
                .tint(.red)
            }
            .frame(height: 50)
        }
    }
    
    
    
}

class FruitListViewModel: ObservableObject {
    @Published var dataToView: [String] = []
    var currentFruitIndex = 0
    var addFruits = ["Фрукт 4", "Фрукт 5", "Фрукт 6"]
    
    var cancellables: Set<AnyCancellable> = []
    
    func addFruit() {
        calculateToAdd()
    }
    
    func removeFruit() {
        guard dataToView.count > 0 else { return }
        _ = dataToView.removeLast()
        if dataToView.count >= 3 {
            currentFruitIndex -= 1
        }
    }
    
    
    func calculateToAdd() {
        switch dataToView.count {
        case 0:
            _ = Just("Яблоко (начальный)")
                .sink { [unowned self] item in
                    dataToView.append(item)
                }
        case 1:
            _ = Just("Банан (начальный)")
                .sink { [unowned self] item in
                    dataToView.append(item)
                }
        case 2:
           _ = Just("Апельсин (начальный)")
                .sink { [unowned self] item in
                    dataToView.append(item)
                }
        default:
            guard currentFruitIndex < addFruits.count else { return }
            _ = addFruits[currentFruitIndex...currentFruitIndex].publisher
                .sink { [unowned self] item in
                    print(item)
                    dataToView.append(item)
                    currentFruitIndex += 1
                }
        }
    }
}


#Preview {
    FruitListView()
}

