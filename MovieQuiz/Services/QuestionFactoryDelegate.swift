//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 08.12.2024.
//

import Foundation


protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error)
}
