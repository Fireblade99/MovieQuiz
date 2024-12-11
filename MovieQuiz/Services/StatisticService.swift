import Foundation

final class StatisticServiceImplementation {
    private let storage: UserDefaults = .standard
    
    // Перечисление для ключей UserDefaults
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case correctAnswers
        case totalQuestions
    }
}

// Реализация протокола
extension StatisticServiceImplementation: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            // Получаем значения для лучшего результата из UserDefaults
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            // Сохраняем значения нового лучшего результата
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        // Рассчитываем общую точность
        let correct = storage.integer(forKey: Keys.correctAnswers.rawValue)
        let total = storage.integer(forKey: Keys.totalQuestions.rawValue)
        return total == 0 ? 0 : Double(correct) / Double(total) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        // Увеличиваем счётчик игр
        gamesCount += 1
        
        // Сохраняем общее количество правильных ответов и вопросов
        let previousCorrect = storage.integer(forKey: Keys.correctAnswers.rawValue)
        let previousTotal = storage.integer(forKey: Keys.totalQuestions.rawValue)
        storage.set(previousCorrect + count, forKey: Keys.correctAnswers.rawValue)
        storage.set(previousTotal + amount, forKey: Keys.totalQuestions.rawValue)
        
        // Проверяем, является ли текущий результат лучшим
        let newResult = GameResult(correct: count, total: amount, date: Date())
        if newResult.isBetterThan(bestGame) {
            bestGame = newResult
        }
    }
}
