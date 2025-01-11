//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 11.01.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showGameResultAlert(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    func showImageError(message: String)
    
    func changeStateButton(isEnabled: Bool)
}
