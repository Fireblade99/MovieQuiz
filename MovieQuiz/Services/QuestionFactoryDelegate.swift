//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 08.12.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didFailToLoadData(with errorMessage: String)
    func didFailToLoadImage(with error: Error)
}
