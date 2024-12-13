import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    private var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    private var alertPresenter: AlertPresenter?
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isInteractionEnabled = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        alertPresenter = AlertPresenter(viewController: self) // Инъекция ViewController
        
        let factory = QuestionFactory()
        factory.delegate = self // Устанавливаем делегата
        self.questionFactory = factory
        
        // Запрашиваем первый вопрос
        questionFactory?.requestNextQuestion()
        
        // Настраиваем кнопки
        noButton.layer.cornerRadius = 15
        noButton.clipsToBounds = true
        yesButton.layer.cornerRadius = 15
        yesButton.clipsToBounds = true
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // Проверяем, что вопрос не nil
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question) // Конвертируем вопрос в QuizStepViewModel
        
        // Обновляем UI в главном потоке
        DispatchQueue.main.async { [weak self] in
            self?.showQuizStep(viewModel) // Используем метод для отображения вопроса
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        questionTitleLabel.text = "Вопрос:"
        questionTitleLabel.textColor = .ypWhite
        counterLabel.textColor = .ypWhite
        textLabel.textColor = .ypWhite
        textLabel.numberOfLines = 0
        noButton.setTitle("Нет", for: .normal)
        yesButton.setTitle("Да", for: .normal)
    }
    
    // MARK: - Logic
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func showQuizStep(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showResults(_ result: QuizResultsViewModel) {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGame = statisticService.bestGame
        
        let message = """
            Текущий результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(totalAccuracy)%
            """
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.presentAlert(model: alertModel)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        guard isInteractionEnabled else { return }
        isInteractionEnabled = false
        
        // Отключаем кнопки
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        if isCorrect { correctAnswers += 1 }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showNextQuestionOrResults()
            self.isInteractionEnabled = true
            
            // Включаем кнопки
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let resultsViewModel = QuizResultsViewModel(
                title: "Результаты",
                text: text,
                buttonText: "Начать заново"
            )
            showResults(resultsViewModel)
        } else {
            currentQuestionIndex += 1 // Увеличиваем индекс текущего вопроса
            questionFactory?.requestNextQuestion()
        }
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Actions
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
