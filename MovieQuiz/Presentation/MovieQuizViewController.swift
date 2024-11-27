import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Data Models
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    // MARK: - Properties
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isInteractionEnabled = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let firstQuestion = convert(model: currentQuestion)
        show(quiz: firstQuestion)
        
        noButton.layer.cornerRadius = 15
        noButton.clipsToBounds = true
        yesButton.layer.cornerRadius = 15
        yesButton.clipsToBounds = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        questionTitleLabel.text = "Вопрос:"
        questionTitleLabel.textColor = .white
        counterLabel.textColor = .white
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        noButton.setTitle("Нет", for: .normal)
        yesButton.setTitle("Да", for: .normal)
    }
    
    // MARK: - Logic
    private var currentQuestion: QuizQuestion {
        return questions[currentQuestionIndex]
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        guard isInteractionEnabled else { return }
        isInteractionEnabled = false
        if isCorrect { correctAnswers += 1 }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.green.cgColor : UIColor.red.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            self.isInteractionEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.clear.cgColor
            if currentQuestionIndex == questions.count - 1 {
                        let viewModel = QuizResultsViewModel(
                            title: "Этот раунд окончен!",
                            text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                            buttonText: "Сыграть ещё раз"
                        )
                        show(quiz: viewModel)
                    } else {
                        currentQuestionIndex += 1
                        let nextQuestion = questions[currentQuestionIndex]
                        let viewModel = convert(model: nextQuestion)
                        show(quiz: viewModel)
                    }
                }
                
                private func show(quiz result: QuizResultsViewModel) {
                    let alert = UIAlertController(
                        title: result.title,
                        message: result.text,
                        preferredStyle: .alert
                    )
                    let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
                        self.currentQuestionIndex = 0
                        self.correctAnswers = 0
                        let firstQuestion = self.questions[self.currentQuestionIndex]
                        let viewModel = self.convert(model: firstQuestion)
                        self.show(quiz: viewModel)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }

                // MARK: - Actions
                @IBAction private func noButtonClicked(_ sender: UIButton) {
                    let givenAnswer = false
                    showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
                }

                @IBAction private func yesButtonClicked(_ sender: UIButton) {
                    let givenAnswer = true
                    showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
                }
            }
