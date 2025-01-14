// GameResult.swift
import Foundation

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    /// Метод для сравнения результатов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
