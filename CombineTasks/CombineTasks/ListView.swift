//
//  ListView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import SwiftUI
import Combine


struct ListView: View {
    @StateObject private var viewModel = ListViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                TextField("Введите строку", text: $viewModel.textFieldInput.value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                HStack(spacing: 70) {
                    Button("Добавить") {
                        viewModel.valueToAdd.value = viewModel.textFieldInput.value
                    }
                    .tint(.green)
                    .disabled(!viewModel.isActive)
                    Button("Очистить список") {
                        viewModel.clearList()
                    }
                    .tint(.red)
                }
                .padding()
            }
            List(viewModel.dataToView.value, id: \.self) { item in
                    Text(item)
            }
            .font(.title)
        }
    }
}

class ListViewModel: ObservableObject {
    @Published var isActive = false
    
    var dataToView = CurrentValueSubject<[String], Never>([])
    var textFieldInput = CurrentValueSubject<String, Never>("")
    var valueToAdd = CurrentValueSubject<String, Never>("")

    var datas: [String?] = []

    var cancellables: Set<AnyCancellable> = []
    
    init() {
        textFieldInput
            .map { newValue -> Bool in
                newValue.isEmpty ? false : true
            }
            .sink { [unowned self] value in
                self.isActive = value
            }
            .store(in: &cancellables)
        
        valueToAdd
            .filter {
                !$0.isEmpty && !$0.contains(" ")
            }
            .sink { [unowned self] newValue in
                datas.append(newValue)
                dataToView.value.removeAll()
                fetch()
                textFieldInput.value = ""
            }
            .store(in: &cancellables)
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
                dataToView.value.append(item)
            }
    }
    
    func clearList() {
        datas.removeAll()
        dataToView.value.removeAll()
        objectWillChange.send()
    }
}

#Preview {
    ListView()
}

