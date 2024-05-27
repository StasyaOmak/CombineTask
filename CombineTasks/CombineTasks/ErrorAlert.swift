//
//  ErrorAlert.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 27/05/2024.
//

import Foundation

struct ErrorForAlert: Error, Identifiable {
    var id = UUID()
    let title = "Error"
    let message: String
}
