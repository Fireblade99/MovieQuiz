import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        
        case total
        case correctAnswers
        case totalCorrectAnswers
        
        case date
        case currentGameDate
        case currentCorrectAnswers
        case currentQuestionsAmount
    }
    
    /// Model for game result data
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
            storage.set(newValue, forKey: Keys.total.rawValue)
            storage.set(newValue, forKey: Keys.date.rawValue)
        }
    }
    
    /// Total games played
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    /// Total correct answers provided
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    /// Calculates answers' accuracy percentage
    var totalAccuracy: Double {
        return Double(totalCorrectAnswers) / Double(gamesCount * 10) * 100.0
    }
    
    /// Processes number of correct answers,  questions, games played. Updates the best game score and date
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let currentCorrectAnswers = storage.integer(forKey: Keys.currentCorrectAnswers.rawValue) + count
        let currentQuestionsAmount = storage.integer(forKey: Keys.currentQuestionsAmount.rawValue) + amount
        let currentGameDate = storage.object(forKey: Keys.currentGameDate.rawValue) as? Date ?? Date()
        
        totalCorrectAnswers += currentCorrectAnswers
        storage.set(currentQuestionsAmount, forKey: Keys.total.rawValue)
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            storage.set(currentCorrectAnswers, forKey: Keys.correct.rawValue)
            storage.set(currentGameDate, forKey: Keys.date.rawValue)
        }
    }
}
