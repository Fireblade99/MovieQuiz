//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 08.12.2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    /// Private var delegate adds support for present() method in showAlert method
    private weak var delegate: UIViewController?
    
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    /// Method which shows round quiz results. Accepts AlertModel and returns nil. Sets alert identifier
    func showAlert(quiz alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default) { _ in
                alertModel.completion()
            }
        
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "Result Alert"
        delegate?.present(alert, animated: true, completion: nil)
    }
}
