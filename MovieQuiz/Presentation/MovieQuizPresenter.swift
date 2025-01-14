import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Internal Property
    /// Var adds support for question factory. E.g. methods requestNextQuestion & func loadData
    var questionFactory: QuestionFactoryProtocol?
    
    // MARK: - Private Properties
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticServiceProtocol?
    private var currentQuestionIndex: Int = .zero
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = .zero
    private var questionsAmount: Int = 10
    
    // MARK: - Initializers
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    // MARK: - Internal Methods
    /// Method for case network data loads successfully. E.g. hides network indicator, requests next question
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    /// Method for case network data load fails. Shows no connection error message
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    /// Method for case network data load fails. Shows server error message
    func didFailToLoadData(with errorMessage: String) {
        let message = errorMessage
        viewController?.showNetworkError(message: message)
    }
    
    /// Method for case network image load fails. Shows no image loaded error message
    func didFailToLoadImage(with error: any Error) {
        viewController?.showImageError(message: "Failed to load image.")
    }
    
    /// Method for converting question to QuizStepViewModel. E.g. image, text, question index/amount
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    /// Method for checking if the next question is shown
    func didReceiveNextQuestion(question: QuizQuestion?) {
        if let question = question {
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        } else {
            // Добавляем лог для диагностики
            print("Error: Received nil question at index \(currentQuestionIndex)")
            assertionFailure("QuestionFactory returned nil question")
        }
    }
    
    /// Method indicating yes/no buttons tapped
    func buttonClicker(isYes: Bool) {
        didAnswer(isYes: isYes)
    }
    
    /// Method sets number of question index/correct answers to zero. Requests next question
    func restartGame() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Private Methods
    /// Private method checks if the last question is reached
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    /// Private method indicating whether the answer is correct or not
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    /// Private method for disabling buttons, highlighting poster border, switching to next question
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.changeStateButton(isEnabled: false)
        
        if isCorrect { correctAnswers += 1 }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    /// Private method to determine whether the question is the last one or not
    private func proceedToNextQuestionOrResults() {
        viewController?.changeStateButton(isEnabled: true)
        
        if self.isLastQuestion() {
            let viewResultsModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз")
            viewController?.showGameResultAlert(quiz: viewResultsModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    /// Private method for counting the amount of answered questions
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    /// Private method calculates game statistics/formats game result message
    private func makeResultsMessage() -> String {
        guard let statisticService = statisticService else {
            assertionFailure("Failed to load statisticService")
            return ""
        }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let resultsMessage = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
        return resultsMessage
    }
}
