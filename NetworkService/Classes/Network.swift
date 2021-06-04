//
//  NetWork.swift
//  MTWebServiceManager
//
//  Created by Everis on 5/17/21.
//

import Foundation

class Network {

    typealias completion = (Result<NetworkResponse, NetworkError>) -> Void
    
    @discardableResult
    func networkTask(provider: NetworkProvider, completion: @escaping completion ) -> URLSessionTask? {
        switch provider.method {
        case .get, .delete:
            return getDataTask(provider: provider, completion: completion)
        case .post, .put:
            return getUploadTask(provider: provider, completion: completion)
        }
    }
    
    func getRequest(provider: NetworkProvider) throws -> URLRequest {
        
        guard let url = URL(networkUri: provider.uri) else {
            throw NetworkError.wrongUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = provider.method.rawValue
        return request
    }
    
    func getSession(provider: NetworkProvider) -> URLSession {
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = provider.header.headers
        
        return URLSession(configuration: sessionConfiguration)
    }
    
    func sendError(error: Error, completion: @escaping completion) {
        guard let error = error as? NetworkError else {
            completion(.failure(.genericError))
            return
        }
        completion(.failure(error))
    }
    
    func parseResponse(dataResponse: Data?, urlResponse: URLResponse?, errorResponse: Error?, completion: @escaping completion) {
        
        if let error = errorResponse,
           let urlResponse = urlResponse as? HTTPURLResponse{
            completion(.failure(.serverError(code: urlResponse.statusCode, message: error.localizedDescription)))
            return
        }
        if let data = dataResponse,
           let urlResponse = urlResponse as? HTTPURLResponse{
            var response = NetworkResponse()
            response.data = data
            response.statusCode = urlResponse.statusCode
            response.headers = urlResponse.allHeaderFields
            completion(.success(response))
            return
        }
    }
    
    func getDataTask(provider: NetworkProvider, completion: @escaping completion ) -> URLSessionDataTask? {
        
        var request: URLRequest
        do{
            request = try getRequest(provider: provider)
        } catch {
            sendError(error: error, completion: completion)
            return nil
        }
        
        let session = getSession(provider: provider)
        
        let task = session.dataTask(with: request) { [weak self] (dataResponse, urlResponse, errorResponse) in
            guard let welf = self else {
                completion(.failure(.genericError))
                return
            }
            welf.parseResponse(dataResponse: dataResponse, urlResponse: urlResponse, errorResponse: errorResponse, completion: completion)
        }
        task.resume()
        return task
    }
    
    func getUploadTask(provider: NetworkProvider, completion: @escaping completion ) -> URLSessionUploadTask? {
        
        var request: URLRequest
        do{
            request = try getRequest(provider: provider)
        } catch {
            sendError(error: error, completion: completion)
            return nil
        }
        
        let session = getSession(provider: provider)
        
        var data: Data?
        do{
            data = try provider.parameters.getBodyData(contentType: provider.header.contentType)
        } catch {
            sendError(error: error, completion: completion)
            return nil
        }
        
        let task = session.uploadTask(with: request, from: data) { [weak self] (dataResponse, urlResponse, errorResponse) in
            guard let welf = self else {
                completion(.failure(.genericError))
                return
            }
            welf.parseResponse(dataResponse: dataResponse, urlResponse: urlResponse, errorResponse: errorResponse, completion: completion)
        }
        task.resume()
        return task
    }
}


