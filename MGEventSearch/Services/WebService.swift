//
//  WebService.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

struct Resource <T: Decodable> {
    let urlRequest: URLRequest
    let parse: (Data) -> T?
}

extension Resource {
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        self.parse = { (raw) -> T? in
            do {
                let parsedDict = try JSONDecoder().decode(T.self, from: raw)
                return parsedDict
            } catch DecodingError.typeMismatch(let key, let context) {
                print(key, context)
            } catch let err {
                print(err)
            }
            return nil
        }
    }
}

public enum Result<Success, Failure: Error> {
    case success(Success), failure(Failure)

    func map<B>(transform: (Success) -> B) -> Result<B, Failure> {
        switch self {
        case .success(let val):
            return .success(transform(val))
        case .failure(let err):
            return .failure(err)
        }
    }
}

enum AppError: Error {
    case invalidURL
    case parsingError
    case networkError(URLError)
    case httpResponse(Int)
    case badResponse
}

class WebService {

    lazy var session = URLSession(configuration: URLSession.shared.configuration)
    private var parameters = [String: String]()
    private var baseURL: String

    init(baseURL: String, parameters: [String: String], session: URLSession? = nil) {
        self.parameters = parameters
        self.baseURL = baseURL
        if let session = session {
            self.session = session
        }
    }

    final func getMe<T>(res: Resource<T>, completion: @escaping (Result<T, AppError>) -> Void) -> URLSessionTask {
        let task = session.dataTask(with: res.urlRequest) { (data, response, err) in
            if let err = err as? URLError {
                print("client error")
                return completion(.failure(.networkError(err)))
            }
            if let httpRes = response as? HTTPURLResponse, !(200..<300 ~= httpRes.statusCode) {
                return completion(.failure(.httpResponse(httpRes.statusCode)))
            }

            guard let data = data, !data.isEmpty else { return completion(.failure(.badResponse)) }
            guard let parsed = res.parse(data) else { return completion(.failure(.parsingError)) }

            completion(.success(parsed))
            }
        task.resume()
        return task
    }

    static func getURL(scheme: String = "https", baseURL: String, path: String,
                       params: [String: String], argsDict: [String: String]?) -> URL? {
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        if let argsDict = argsDict {
            for (key, value) in argsDict {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        var components = URLComponents()
        components.scheme = scheme
        components.host = baseURL
        components.path = path
        components.queryItems = queryItems
        return components.url
    }

    final func prepareResource<T: Decodable>(page: Int? = nil, pageSize: Int? = nil, pathForREST: String,
                                             argsDict: [String: String] = [: ], parse: ((Data) -> T?)? = nil) throws -> Resource<T> {
        if let page = page {
            parameters["page"] = String(page)
        }
        if let pageSize = pageSize {
            parameters["pageSize"] = String(pageSize)
        }

        guard let completeURL = WebService.getURL(baseURL: baseURL, path: pathForREST,
                                                  params: parameters, argsDict: argsDict) else { throw AppError.invalidURL }
        let request = URLRequest(url: completeURL)
        if let parse = parse {
            return Resource<T>(urlRequest: request, parse: parse)
        }
        return Resource<T>(urlRequest: request)
    }

}
