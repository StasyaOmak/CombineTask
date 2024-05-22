//
//  ContentView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import Foundation
import Combine

class TaxiViewModel: ObservableObject {
    
    @Published var message = ""
    @Published var status = ""
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = $message
            .dropFirst()
            .map { [unowned self] value -> String in
                self.status = "Ищем машину..."
                return value
            }
            .delay(for: 7, scheduler: DispatchQueue.main)
            .sink { [unowned self] value in
                self.message = "Водитель приедет через 10 минут"
                self.status = "Машина найдена"
            }
    }
    
    func refresh() {
        message = "Идет поиск свободных машин..."
    }
    
    func cancel() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.status = "Заказ отменен"
            self.cancellable?.cancel()
            self.cancellable = nil
            self.message = ""
        }
    }
}

