//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 11.12.2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    // Метод для сравнения результатов
    func isBetterThan(_ another: GameResult) -> Bool {
        return correct > another.correct
    }
}
