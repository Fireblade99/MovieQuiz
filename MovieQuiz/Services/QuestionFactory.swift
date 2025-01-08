//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 07.12.2024.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - Properties
    //    private let questions: [QuizQuestion] = [
    //        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    //    ]
    
    private var movies: [MostPopularMovie] = []
    
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else {
                print("Фильм не найден по индексу")
                return
            }
            
            let imageData = Data()
            let task = URLSession.shared.dataTask(with: movie.resizedImageURL) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        let question = QuizQuestion(image: data, text: "Рейтинг этого фильма больше чем 7?", correctAnswer: Float(movie.rating ?? "0") ?? 0 > 7)
                        self.delegate?.didReceiveNextQuestion(question: question)
                    }
                } else if let error = error {
                    print("Ошибка загрузки изображения: \(error.localizedDescription)")
                }
            }
            task.resume()

            
            let rating = Float(movie.rating ?? "0") ?? 0
            let text = "Рейтинг этого фильма больше чем \(rating > 7 ? "7" : "5")?"

            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
}

