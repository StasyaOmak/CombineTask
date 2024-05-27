//
//  ViewState.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 27/05/2024.
//

import Foundation

enum ViewState<Model> {
    case loading
    case data(_ data: Model)
    case error(_ error: Error)
}
