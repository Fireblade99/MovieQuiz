//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 08.12.2024.
//

import Foundation

struct AlertModel {
    /// Headline of alert
    var title: String
    /// Text of alert's message
    var message: String
    /// Text of alert's button
    var buttonText: String
    /// Closure without parameters for action button alert
    let completion: () -> Void
}
