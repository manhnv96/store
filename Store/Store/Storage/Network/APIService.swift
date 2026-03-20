//
//  APIService.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 19/4/25.
//

import Combine
import Foundation

enum APIError: Error {
    case invalidParameters
    case InvalidResponse
    case responseNotMeetCondition(data: Data, response: URLResponse)
}

protocol APIRequestable {
    typealias ValidateSuccessCondition = (Data, URLResponse) throws -> Bool
    var request: URLRequest? { get }
    var successCondition: ValidateSuccessCondition? { get }
    var dataTaskPublisher: URLSession.DataTaskPublisher { get }
}

extension APIRequestable {
    var dataTaskPublisher: URLSession.DataTaskPublisher? {
        guard let request else {
            return nil
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
    }
}

protocol APIService {
    typealias APIDataResult = Result<(data: Data, response: URLResponse), Error>
    func data(from requestable: APIRequestable) -> AnyPublisher<APIDataResult, Error>
    func object<T: Decodable>(from requestable: APIRequestable) async -> Result<T, Error>
    func object<T: Decodable>(_ type: T, from requestable: APIRequestable) async -> Result<T, Error>
}

extension APIService {
    func data(from requestable: APIRequestable) -> AnyPublisher<APIDataResult, Error> {
        guard let request = requestable.request else {
            return Fail(error: APIError.invalidParameters).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> APIDataResult in
                if let condition = try requestable.successCondition?(data, response) {
                    if condition {
                        return .failure(APIError.responseNotMeetCondition(data: data, response: response))
                    } else {
                        return .success((data, response))
                    }
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.InvalidResponse
                }
                
                if 200...300 ~= httpResponse.statusCode {
                    return .success((data: data, response: response))
                }
                
                return .failure(APIError.responseNotMeetCondition(data: data, response: response))
            }
            .eraseToAnyPublisher()

    }
}
