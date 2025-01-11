//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Руслан Руцкой on 06.01.2025.
//
import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

/// Network struct for providing loading data functionality via URL
struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    /// Method for loading data via URLSession, returning response via HTTPURLResponse and providing data if request is successful
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}
