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
            
            // Загрузка изображения напрямую через Data(contentsOf:)
            let imageData: Data
            do {
                imageData = try Data(contentsOf: movie.imageURL)
                print("Изображение успешно загружено для \(movie.title)")
            } catch {
                print("Ошибка загрузки изображения для \(movie.title): \(error)")
                return
            }
            
            // Генерация случайного значения рейтинга
            let randomRating = Float.random(in: 5.0...9.0)
            
            // Генерация случайного типа вопроса
            let isGreaterThan = Bool.random()
            
            // Формирование текста вопроса
            let questionText = isGreaterThan ?
            "Рейтинг этого фильма больше чем \(String(format: "%.1f", randomRating))?" :
            "Рейтинг этого фильма меньше чем \(String(format: "%.1f", randomRating))?"
            
            // Определение правильного ответа
            let movieRating = Float(movie.rating ?? "0") ?? 0
            let correctAnswer = isGreaterThan ? (movieRating > randomRating) : (movieRating < randomRating)
            
            // Создаём вопрос
            let question = QuizQuestion(
                image: imageData,
                text: questionText,
                correctAnswer: correctAnswer
            )
            
            // Обновляем UI в главном потоке
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

}

