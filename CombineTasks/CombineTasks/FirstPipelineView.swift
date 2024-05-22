//
//  FirstPipelineView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 20/05/2024.
//

import SwiftUI
import Combine

struct FirstPipelineView: View {
    @StateObject var viewModel = FirstPipeLineViewModel()
    @State private var shouldShowAlert = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("Ваше имя", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text(viewModel.nameValidation)
            }
            .padding()
            HStack {
                TextField("Ваша фамилия", text: $viewModel.surname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text(viewModel.surnameValidation)
            }
            .padding()
            Button {
                shouldShowAlert.toggle()
                viewModel.checkValidation()
            } label: {
                Text("Register")
                    .padding()
                    .frame(width: 150, height: 100)
                    .background(.yellow)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
    }
}


class FirstPipeLineViewModel: ObservableObject {
    @Published var name = ""
    @Published var surname = ""
    @Published var nameValidation = ""
    @Published var surnameValidation = ""
    @Published var isValidationSuccessful = false
    
    init() {
        $name
            .map { $0.isEmpty || $0.rangeOfCharacter(from: .decimalDigits) != nil ? "❌" : "✅" }
            .assign(to: &$nameValidation)
        
        $surname
            .map { $0.isEmpty || $0.rangeOfCharacter(from: .decimalDigits) != nil ? "❌" : "✅" }
            .assign(to: &$surnameValidation)
        
    }
    
    func checkValidation() {
            isValidationSuccessful = nameValidation == "✅" && surnameValidation == "✅" ? true : false
    
    }
}



#Preview {
    FirstPipelineView()
}
