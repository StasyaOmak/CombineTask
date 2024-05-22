//
//  TaxiView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//

import SwiftUI
import Combine

struct TaxiView: View {
    
    @StateObject var taxiViewModel = TaxiViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            Text(taxiViewModel.message)
                .font(.headline)
                .foregroundColor(.green)
            Text(taxiViewModel.status)
                .foregroundColor(.blue)
            Spacer()
            Button {
                taxiViewModel.cancel()
            } label: {
                Text("Отменить заказ")
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
            }
            .background(.red)
            .cornerRadius(8)
            
            Button {
                taxiViewModel.refresh()
            } label: {
                Text("Заказать такси")
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
            }
            .background(.yellow)
            .cornerRadius(8)
            .padding()
        }
    }
}

#Preview {
    TaxiView()
}

