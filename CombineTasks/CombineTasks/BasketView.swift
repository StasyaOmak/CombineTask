//
//  ContentView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import SwiftUI
import Combine

struct Product: Identifiable {
    var id = UUID()
    var name: String
    var price: Int
}

struct BasketView: View {
    @StateObject private var viewModel = BasketViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.products.indices, id: \.self) { index in
                HStack() {
                    Text(viewModel.products[index].name)
                    Stepper("") {
                        if viewModel.addedProducts.allSatisfy({ $0.id != viewModel.products[index].id }) {
                            viewModel.addedProducts.append(viewModel.products[index])
                        }
                    } onDecrement: {
                        if let position = viewModel.addedProducts.firstIndex(where: { $0.id == viewModel.products[index].id }) {
                            viewModel.addedProducts.remove(at: position)
                        }
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
                .frame(height: 100)
            VStack(spacing: 10) {
                HStack {
                    Text("Товар")
                    Spacer()
                    Text("Цена")
                }
                .padding(.horizontal)
                .font(.custom("Verdana-bold", size: 20))
                ForEach(viewModel.check, id: \.id) { product in
                    HStack {
                        Text(product.name)
                        Spacer()
                        Text(String(product.price))
                    }
                    .padding(.horizontal)
                }
                Spacer()
                    .frame(height: 10)
                Text("Итоговая сумма: \(String(viewModel.totalSum))")
            }
            Spacer()
            Button {
                viewModel.clearBasket()
            } label: {
                Text("Очистить корзину")
            }

        }
    }
}

class BasketViewModel: ObservableObject {
    @Published var addedProducts: [Product] = []
    @Published var check: [Product] = []
    @Published var totalSum = 0

    var products: [Product] = [
        .init(name: "Сметана 300 г.", price: 300),
        .init(name: "Хлеб", price: 50),
        .init(name: "Свекла 300 г.", price: 100),
    ]
    
    private var basketCancellables: Set<AnyCancellable> = []

    var totalSum1: Int {
        check.reduce(0) { $0 + $1.price }
    }
    
    init() {
        $addedProducts
            .map { products in
                products.filter { $0.price <= 1000 }
            }
            .sink { [unowned self] products in
                check = products
            }
            .store(in: &basketCancellables)
        
        $check
            .dropFirst()
            .scan(100) { accumulatedSum, newProducts in
                accumulatedSum + newProducts.reduce(0) { $0 + $1.price }
            }
            .sink { sum in
                self.totalSum = sum
            }
            .store(in: &basketCancellables)

        $check
            .dropFirst()
            .combineLatest($addedProducts)
            .map { check, addedProducts -> Int in
                let filteredCheck = check.filter { product in
                    addedProducts.contains { $0.id == product.id }
                }
                return 100 + filteredCheck.reduce(0) { $0 + $1.price }
            }
            .sink { [unowned self] sum in
                self.totalSum = sum
            }
            .store(in: &basketCancellables)
    }
    
    func clearBasket() {
        basketCancellables.removeAll()
        check.removeAll()
        addedProducts.removeAll()
        totalSum = 0
    }
}

#Preview {
    BasketView()
}

