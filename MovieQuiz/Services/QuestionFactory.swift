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
                    if mostPopularMovies.items.isEmpty {
                        self.delegate?.didFailToLoadData(with: "No movies available")
                    } else {
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error.localizedDescription)
                }
            }
        }
    }

    func requestNextQuestion() {
        print("Количество фильмов: \(movies.count)")
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard !self.movies.isEmpty else {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: "Массив фильмов пуст")
                }
                return
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard index < self.movies.count, let movie = self.movies[safe: index] else {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: "Индекс вышел за пределы массива")
                }
                return
            }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadImage(with: error)
                }
                return
            }
            
            let randomQuestions = [
                "Рейтинг этого фильма больше чем 5",
                "Рейтинг этого фильма больше чем 7",
                "Рейтинг этого фильма больше чем 9",
                "Рейтинг этого фильма меньше чем 5",
                "Рейтинг этого фильма меньше чем 7",
                "Рейтинг этого фильма меньше чем 9"
            ]
            let randomIndex = (0...5).randomElement() ?? 0
            let text = randomQuestions[randomIndex]
            
            let rating = Float(movie.rating) ?? 0
            let correctAnswer: Bool
            
            switch randomIndex {
            case 0: correctAnswer = rating > 5
            case 1: correctAnswer = rating > 7
            case 2: correctAnswer = rating > 9
            case 3: correctAnswer = rating < 5
            case 4: correctAnswer = rating < 7
            case 5: correctAnswer = rating < 9
            default: correctAnswer = false
            }
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

}
