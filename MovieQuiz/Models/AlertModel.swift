//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 08.12.2024.
//

import Foundation

struct AlertModel {
    let title: String      // Заголовок алерта
    let message: String    // Сообщение
    let buttonText: String // Текст кнопки
    let completion: (() -> Void)? // Замыкание, выполняемое при нажатии на кнопку
}

