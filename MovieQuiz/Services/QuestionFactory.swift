//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 07.12.2024.
//
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    /// Method allows factory to load data or show an error in case of network failure
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.items.count != 0 {
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    } else {
                        self.delegate?.didFailToLoadData(with: mostPopularMovies.errorMessage)
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error.localizedDescription)
                    
                }
            }
        }
    }
    
    /// Method allows factory to create and return random questions
    func requestNextQuestion() {
        let randomQuestions = [
            "Рейтинг этого фильма больше чем 5",
            "Рейтинг этого фильма больше чем 7",
            "Рейтинг этого фильма больше чем 9",
            "Рейтинг этого фильма меньше чем 5",
            "Рейтинг этого фильма меньше чем 7",
            "Рейтинг этого фильма меньше чем 9"]
        let arrayOfQuestions = (0...5).randomElement() ?? 0
        let text = randomQuestions[arrayOfQuestions]
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadImage(with: error)
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let correctAnswer: Bool
            
            switch arrayOfQuestions {
            case 1: correctAnswer = rating > 5
            case 2: correctAnswer = rating > 9
            case 3: correctAnswer = rating < 5
            case 4: correctAnswer = rating < 7
            case 5: correctAnswer = rating < 9
            default: correctAnswer = rating > 7
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
