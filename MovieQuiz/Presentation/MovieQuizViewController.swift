import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol  {
    
    // MARK: - IB Outlets
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    /// Private var adds business logic support from MovieQuizPresenter
    private var presenter: MovieQuizPresenter?
    /// Private var adds support for showing game result/network failure alerts
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTitleLabel.textColor = UIColor.ypWhite
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - IBActions
    /// Method indicating yes button tapped
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.buttonClicker(isYes: true)
    }
    
    /// Method indicating no button tapped
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.buttonClicker(isYes: false)
    }
    
    // MARK: Internal Methods
    /// Method for showing question - image, image border highlight, question, number of questions
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    /// Game result alert showing game final
    func showGameResultAlert(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter?.restartGame()
            }
        )
        alertPresenter?.showAlert(quiz: alertModel)
    }
    
    /// Method to indicate whether the answer correct or not. E.g. Image poster border highlights in green/red
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    /// Method for showing network load indicator
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    /// Method for hiding network load indicator
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    /// Method showing an error in case of network failure
    func showNetworkError(message: String) {
        let alertConnectionError = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self ] in
                guard let self = self else { return }
                presenter?.questionFactory?.loadData()
            }
        alertPresenter?.showAlert(quiz: alertConnectionError)
    }
    
    /// Method showing an error in case of failure to load poster. Restarts the game
    func showImageError(message: String) {
        showLoadingIndicator()
        let alertImageError = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self ] in
                guard let self = self else { return }
                presenter?.restartGame()
                presenter?.questionFactory?.loadData()
            }
        alertPresenter?.showAlert(quiz: alertImageError)
    }
    
    /// Changes enable/disable state for yes/no buttons
    func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
}
