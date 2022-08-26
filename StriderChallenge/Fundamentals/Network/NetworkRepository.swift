//
//  NetworkRepository.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 26/08/22.
//

import Foundation

enum Result<Success, Error: Swift.Error> {
    case success(Success)
    case failure(Error)
}

extension Result {
    func get() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

extension Result where Success == Data {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init()) throws -> T {
        let data = try get()
        return try decoder.decode(T.self, from: data)
    }
}

protocol NetworkRepositoryProtocol {
    @discardableResult
    func request<T: Codable>(for url: URL, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask?
    @discardableResult
    func requestData<K: Encodable, R: Decodable>(for url: URL, httpBody: K, completion: @escaping (Result<R, Error>) -> Void) -> URLSessionDataTask?
}

final class NetworkRepository: NetworkRepositoryProtocol {
    public func request<T: Codable>(for url: URL, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask? {
        let session = URLSession.shared
        let url = url
        print(url)
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                completion(.failure(error!))
            }
            
            guard let dataResponse = data else { return }
            do {
                let responseData = try JSONDecoder().decode(T.self, from: dataResponse)
                completion(.success(responseData))
            } catch  let jsonError {
                print(jsonError)
                completion(.failure(jsonError))
            }
        })
        task.resume()
        return task
    }
    
    public func requestData<K: Encodable, R: Decodable>(for url: URL, httpBody: K, completion: @escaping (Result<R, Error>) -> Void) -> URLSessionDataTask? {
        let session = URLSession.shared
        var urlRequest = URLRequest(url: url)
        var jsonData: Data = Data()
        do {
            jsonData = try JSONEncoder().encode(httpBody)
        } catch let errorJSON {
            completion(.failure(errorJSON))
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        
        let task = session.dataTask(with: urlRequest) { (data, resopne, error) in
            if error != nil {
                completion(.failure(error!))
            }
            guard let dataResponse = data else { return }
            do {
                let responseData = try JSONDecoder().decode(R.self, from: dataResponse)
                completion(.success(responseData))
            } catch  let jsonError {
                completion(.failure(jsonError))
            }
        }
        task.resume()
        return task
    }
}
