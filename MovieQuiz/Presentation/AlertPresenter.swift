//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 08.12.2024.
//

import UIKit

class AlertPresenter {
    private weak var viewController: UIViewController? // Контроллер, который будет показывать алерт
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?() // Выполняем замыкание, если оно есть
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
