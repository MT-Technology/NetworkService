//
//  WebServiceManager.swift
//  webService
//
//  Created by Mateo Espinoza on 4/03/18.
//  Copyright © 2018 Mateo Espinoza. All rights reserved.
//

import Foundation
import UIKit

/**
 Enumerate to define web service method.
 */
private enum MTWebServiceMethod : String{
    
    /// POST method
    case post   = "POST"
    /// GET method
    case get    = "GET"
    /// PUT method
    case put    = "PUT"
    /// DELETE method
    case delete = "DELETE"
    /// PATCH method
    case patch  = "PATCH"
}

/**
 Enumerate to define the Content Type value in the header request.
 */
public enum MTWebServiceContentType: String {
    
    /// This Content type is define as Multipart Form data web services
    case formData   = "multipart/form-data; boundary=WebServiceManager.boundary"
    /// This Content type is define as Raw web services
    case raw        = "application/json"
    /// This Content type is define as x-www-form-urlencoded
    case urlEncoded = "application/x-www-form-urlencoded"
    /// This Content type is empty
    case none       = ""
}


/**
 Enumerate to define the web service's response
 */
public enum MTWebServicesResponseStatus: Int {
    
    /// The web service's response is success.
    case success = 0
    /// The web service's response is failure when ocurred some error.
    case failure
    /// The web service's response is cancelled when the request is cancelled by user.
    case cancelled
    /// The web service's response is badURL when the url is wrong
    case badURL
    /// The web service's response is timeout when request not response in setup time.
    case timeout
    /// The web service's response is cannotFindSerer when request can't find the host/server
    case cannotFindServer
    /// The web service's response is cannotConnectToServer when request can't connect to host/server
    case cannotConnectToServer
    /// The web service's response is networkConnectionLost when request lost internet connection in middle request
    case networkConnectionLost
    /// The web service's response status is unauthorized when doesn't have access token.
    case unauthorized
    /// The web service's response status is forbidden when doesn's have privileges.
    case forbidden
    /// The web service's response status is noInternetConnectio when the device doesn't have internet connection.
    case noInternetConnection
    /// The web service's response is badServerResponse when the host/server has a error
    case badServerResponse
    /// The web service's response neutral or void
    case none
}


/**
 Enumerate to define the web service's error message
 */
private enum MTWebServicesErrorMessage: String {
    
    /// The message error when the response status is failure
    case failure                = "Se perdió la conexión con el servidor. Por favor, inténtalo más tarde."
    /// The message error when the url is wrong
    case badURL                 = "Lo sentimos, la url a la que intenta acceder no existe."
    /// The message error when the response status is timeout
    case timeout                = "Se terminó el tiempo de espera."
    /// The message error when request can't find the host/server
    case cannotFindServer       = "Lo sentimos, no se puede encontrar el servidor."
    /// The message error when request can't connect to host/server
    case cannotConnectToServer  = "Lo sentimos, en estos momentos no se puede conectar con el servidor."
    /// The message error when request lost internet connection in middle request
    case networkConnectionLost  = "Se perdio la conexión a internet.\nPor favor conéctate a una red y vuelve a interntarlo."
    /// The message error when the response status is unauthorized.
    case unauthorized           = "La sesión ha expirado o es inválida.\nPor favor, vuelva a iniciar sesión."
    /// The message error when the response status is forbbin.
    case forbidden              = "Lo sentimos, no cuenta con los permisos para acceder a esta información."
    /// The message error when the response is failure
    case noInternetConnection   = "No hay conexión a internet.\nPor favor conéctate a una red y vuelve a intentarlo."
    /// The message error when the host/server has a error
    case badServerResponse      = "Lo sentimos, en estos momentos el servidor no puede resolver tu petición."
}


/**
 
 */
private class MTWebServiceFactorySessionTask{
    
    private init() {}
    
    /**
     
     - Parameter method: Web service methods as `WebServiceMethod`
     - Parameter data:
     - Parameter session:
     - Parameter request:
     - Parameter completionHandler:
     - Returns:
     */
    class func getURLSessionTask(method : MTWebServiceMethod, data : Data?, session : URLSession, request : URLRequest, completionHandler: @escaping (_ webServiceResponse: MTWebServiceResponse) -> Void)->URLSessionTask{
        
        switch method {
        case .get:
            
            let dataTask = session.dataTask(with: request, completionHandler: { (data: Data?, urlResponse : URLResponse?, error : Error?) in
                MTWebserviceResponseParse.responseParse(data: data, urlResponse: urlResponse, error: error, completionHandler: completionHandler)
            })
            return dataTask
            
        case .post,.delete,.put:
            
            let dataTask = session.uploadTask(with: request, from: data, completionHandler: { (data : Data?, urlResponse : URLResponse?, error : Error?) in
                MTWebserviceResponseParse.responseParse(data: data, urlResponse: urlResponse, error: error, completionHandler: completionHandler)
            })
            
            return dataTask
            
        default:
            break
        }
        
        return URLSessionTask()
    }
}

/**
 */
private class MTWebserviceResponseParse {
    
    /**
     
     - Parameter error:
     - Returns:
     */
    private class func statusAndMessageForError(_ error: Error) -> (MTWebServicesResponseStatus, String?) {
        var stateAndMessage: (MTWebServicesResponseStatus, String?)
        
        switch (error as NSError).code {
        case NSURLErrorCancelled:
            stateAndMessage = (.cancelled, nil)
        case NSURLErrorBadURL:
            stateAndMessage = (.badURL, MTWebServicesErrorMessage.badURL.rawValue)
        case NSURLErrorTimedOut:
            stateAndMessage = (.timeout, MTWebServicesErrorMessage.timeout.rawValue)
        case NSURLErrorCannotFindHost:
            stateAndMessage = (.cannotFindServer, MTWebServicesErrorMessage.cannotFindServer.rawValue)
        case NSURLErrorCannotConnectToHost:
            stateAndMessage = (.cannotConnectToServer, MTWebServicesErrorMessage.cannotConnectToServer.rawValue)
        case NSURLErrorNetworkConnectionLost:
            stateAndMessage = (.networkConnectionLost, MTWebServicesErrorMessage.networkConnectionLost.rawValue)
        case NSURLErrorNotConnectedToInternet:
            stateAndMessage = (.noInternetConnection, MTWebServicesErrorMessage.noInternetConnection.rawValue)
        case NSURLErrorBadServerResponse:
            stateAndMessage = (.badServerResponse, MTWebServicesErrorMessage.badServerResponse.rawValue)
        default:
            stateAndMessage = (.failure, MTWebServicesErrorMessage.failure.rawValue)
        }
        
        return stateAndMessage
    }
    
    /**
     
     - Parameter httpStatusCode:
     - Returns:
     */
    private class func statusAndMessageForHttpStatusCode(_ httpStatusCode: Int) -> (MTWebServicesResponseStatus, String?) {
        
        var stateAndMessage: (MTWebServicesResponseStatus, String?)
        
        switch httpStatusCode {
        case 200:
            stateAndMessage = (.success, nil)
        case 401:
            stateAndMessage = (.unauthorized, MTWebServicesErrorMessage.unauthorized.rawValue)
        case 403:
            stateAndMessage = (.forbidden, MTWebServicesErrorMessage.forbidden.rawValue)
        default:
            stateAndMessage = (.failure, MTWebServicesErrorMessage.failure.rawValue)
        }
        
        return stateAndMessage
    }
    
    /**
     
     - Parameter data: Is the response's web service as Data
     - Parameter urlResponse:
     - Parameter error: This value is nill if doesn't ocurred any error.
     - Parameter completionHandler: Code block who contain a `WebServiceResponse` struct
     */
    public class func responseParse(data: Data?, urlResponse : URLResponse?, error : Error?, completionHandler: @escaping (_ webServiceResponse: MTWebServiceResponse) -> Void){
        
        DispatchQueue.global(qos: .background).async {
            var response: Any? = nil
            if error == nil {
                do {
                    response = try JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)
                }
                catch {
                    print("\(self) - \(#function) / Error al intentar parsear la respuesta del servicio web.")
                }
            }
            
            var webServiceResponse = MTWebServiceResponse()
            webServiceResponse.responseData = data
            let httpUrlResponse = urlResponse as? HTTPURLResponse
            if let _ = error {
                let (status, message) = self.statusAndMessageForError(error!)
                webServiceResponse.status = status
                webServiceResponse.errorMessage = message ?? ""
                webServiceResponse.statusCode = httpUrlResponse?.statusCode ?? 404
                DispatchQueue.main.async(execute: {
                    completionHandler(webServiceResponse)
                })
            }else {
                let (status, message) = self.statusAndMessageForHttpStatusCode(httpUrlResponse?.statusCode ?? 404)
                webServiceResponse.status = status
                webServiceResponse.errorMessage = message ?? ""
                webServiceResponse.response = response
                webServiceResponse.statusCode = httpUrlResponse?.statusCode ?? 404
                
                print(response ?? "No hay respuesta del servicio")
                
                let headers = httpUrlResponse?.allHeaderFields as? [String: Any]
                webServiceResponse.headers = headers
                DispatchQueue.main.async(execute: {
                    completionHandler(webServiceResponse)
                })
            }
        }
    }
}

/**
 `WebServiceResponse` is the struct containt the web service's response.
 */
public struct MTWebServiceResponse {
    
    /// `JSON` contain de web service's response
    public var response: Any? = nil
    /// `WebServicesResponseStatus` is a value to contain the response's status
    public var status  : MTWebServicesResponseStatus = .none
    /// This value contain the error message if the status is different to success
    public var errorMessage = ""
    /// This value contain the response's headers
    public var headers : [String: Any]? = nil
    
    public var statusCode: Int = 0
    
    public var responseData: Data? = nil
    init() {
        
    }
}

/**
 `WebServiceHeaderRequest` is the class who to create the header's body
 */
public class MTWebServiceHeaderRequest{
    
    /// `WebServiceContentType` is a value who define the header's request type
    public var contentType             : MTWebServiceContentType = .raw
    /// Use this value if you want to change the request's setup time
    public var timeoutRequest          : TimeInterval = 60.0
    /// Use this value if you want to add extra headers
    public var httpAdditionalHeaders   : [String : Any]?
    
    public init() {
        
    }
    
    /**
     This function set the headers and the setup time in the sessionConfiguration
     - Parameter sessionConfiguration: In this URLSessionConfiguration will be set the headers and the setup time.
     */
    public func setConfiguration(sessionConfiguration : URLSessionConfiguration){
        
        self.setHeaders(sessionConfiguration: sessionConfiguration)
        self.setTimeOut(sessionConfiguration: sessionConfiguration)
    }
    
    /**
     This function set the headers in the sessionConfigurations
     Use the contentType value to set the Content-Type header
     Use the needTokenAuthorization value to se the Authorization header
     Use the httpAdditionalHeaders to set another header in the sessionConfiguration
     - Parameter sessionConfiguration: In this URLSessionConfiguration will be set the headers.
     */
    private func setHeaders(sessionConfiguration : URLSessionConfiguration){
        
        var headers = [String: Any]()
        
        if self.contentType != .none{
            headers["Content-Type"] = self.contentType.rawValue
        }
        
        if let additionalHeaders = self.httpAdditionalHeaders{
            for (key,value) in additionalHeaders{
                headers[key] = value
            }
        }
        
        sessionConfiguration.httpAdditionalHeaders = headers
        
    }
    
    /**
     This function set in the sessionConfiguration the setup time
     - Parameter sessionConfiguration: In this URLSessionConfiguration will be set the setup time
     */
    private func setTimeOut(sessionConfiguration : URLSessionConfiguration){
        
        sessionConfiguration.timeoutIntervalForRequest = self.timeoutRequest
    }
}

/**
 `WebServiceBodyRequest` is the class who to create the request's body
 */
private class MTWebServiceBodyRequest {
    
    /// `WebServiceContentType` is a value who define the body's request type
    private let contentType : MTWebServiceContentType
    /// This array containt the body's parameters. The parameters are ['key':'value']
    private let parameters  : [String : Any]?
    
    init(contentType : MTWebServiceContentType, parameters : [String:Any]?) {
        
        self.contentType = contentType
        self.parameters = parameters
    }
    
    /**
     This function transform the parameters array to body's request
     - Returns: body's request as Data
     */
    public func getBodyRequest() -> Data {
        
        switch self.contentType {
            
        case .raw:
            return self.rawParseParameters()
        case .formData:
            return self.formDataParseParameters()
        case .urlEncoded:
            return self.formDataURLParameters()
        default:
            return Data()
            
        }
    }
    
    /**
     This function transform the paramenters array to Raw body's request
     - Returns:  Raw body's request as Data
     */
    private func rawParseParameters() -> Data{
        
        if let parametersToParse = self.parameters{
            
            do{
                return try JSONSerialization.data(withJSONObject: parametersToParse, options: JSONSerialization.WritingOptions.prettyPrinted)
            }catch{
                return Data()
            }
        }
        else{
            return Data()
        }
    }
    
    private func formDataURLParameters() -> Data {
        
        guard let parameters = self.parameters else {
            return Data()
        }
        
        var components: [(String, String)] = []
        
        for (key, value) in parameters {
            components += queryComponents(fromKey: key, value: value)
        }
        
        let queryString = components.map { "\($0)=\($1)" }.joined(separator: "&")
        
        return queryString.data(using: .utf8, allowLossyConversion: false) ?? Data()
    }
    
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape(value.boolValue ? "1" : "0")))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape(bool ? "1" : "0")))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    private  func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        let escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        
        return escaped
    }
    
    /**
     This function transform the paramenters array to MultipartForm-Data body's request
     - Returns:  MultipartForm-Data body's request as Data
     */
    private func formDataParseParameters() -> Data{
        
        if let parametersToParse = self.parameters{
            
            var formData = Data()
            let divisor = "--WebServiceManager.boundary\r\n"
            let ending = "--WebServiceManager.boundary--\r\n"
            
            for(key, value) in parametersToParse{
                
                formData.append(divisor.data(using: String.Encoding.utf8)!)
                if value is UIImage{
                    
                    let image_data = (value as! UIImage).pngData()
                    
                    formData.append("Content-Disposition:form-data; name=\"\(key)\"; filename=\"picture.png\"\r\n".data(using: String.Encoding.utf8)!)
                    formData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
                    formData.append(image_data!)
                    formData.append("\r\n".data(using: String.Encoding.utf8)!)
                    
                }
                else{
                    formData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8) ?? Data())
                    formData.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
                }
            }
            
            if formData.count > 0{
                formData.append(ending.data(using: String.Encoding.utf8) ?? Data())
            }
            
            return formData
        }else{
            return Data()
        }
    }
}

/**
 `WebServiceRequest` is the class who send web service's request
 */
public class MTWebServiceRequest{
    
    /**
     This function is to consume a web service using the any web service's method.
     - Parameter method: `WebServiceMethod` value, is the web service's method.
     - Parameter urlString: This is the url to Web Service.
     - Parameter header: `WebServiceHeader`, is the header for request. This value is optional.
     - Parameter parameters: This array containt body's values for request.
     - Parameter completionHandler: Code block who contain web service response
     - Returns: A `URLSessionTask` object
     */
    private func webServiceRequest(method : MTWebServiceMethod,
                                   urlString : String,
                                   header : MTWebServiceHeaderRequest = MTWebServiceHeaderRequest(),
                                   parameters : [String : Any]?,
                                   completionHandler: @escaping (_ webServiceResponse: MTWebServiceResponse) -> Void) -> URLSessionTask {
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let sessionConfiguration = URLSessionConfiguration.default
        header.setConfiguration(sessionConfiguration: sessionConfiguration)
        
        let bodyRequest = MTWebServiceBodyRequest(contentType: header.contentType, parameters: parameters)
        let data = bodyRequest.getBodyRequest()
        
        //        let session : URLSession = URLSession(configuration: sessionConfiguration)
        let session  = URLSession(configuration: sessionConfiguration, delegate: SSLSessionDelegate(), delegateQueue: nil)
        
        let task = MTWebServiceFactorySessionTask.getURLSessionTask(method: method, data: data, session: session, request: request, completionHandler: completionHandler)
        
        task.resume()
        return task
    }
    
    
    /**
     This function is to consume a web service using the POST method
     - Parameter urlString: This is the url to Web Service.
     - Parameter header: `WebServiceHeader`, is the header for request. This value is optional.
     - Parameter parameters: This array containt body's values for request.
     - Parameter completionHandler: Code block who contain web service response
     - Returns: A `URLSessionTask` object
     */
    @discardableResult public func postRequest(urlString : String,
                                               header : MTWebServiceHeaderRequest = MTWebServiceHeaderRequest(),
                                               parameters : [String : Any]?,
                                               completionHandler: @escaping (_ webServiceResponse: MTWebServiceResponse) -> Void) -> URLSessionTask {
        
        return self.webServiceRequest(method: .post, urlString: urlString, header: header, parameters: parameters, completionHandler: completionHandler)
    }
    
    
    /**
     This function is to consume a web service using the GET method
     - Parameter urlString: This is the url to Web Service.
     - Parameter header: `WebServiceHeader`, is the header for request. This value is optional.
     - Parameter parameters: This array containt body's values for request.
     - Parameter completionHandler: Code block who contain web service response
     - Returns: A `URLSessionTask` object
     */
    @discardableResult public func getRequest(urlString : String,
                                              header : MTWebServiceHeaderRequest = MTWebServiceHeaderRequest(),
                                              parameters : [String : Any]?,
                                              completionHandler: @escaping (_ webServiceResponse: MTWebServiceResponse) -> Void) -> URLSessionTask {
        
        return self.webServiceRequest(method: .get, urlString: urlString, header: header, parameters: parameters, completionHandler: completionHandler)
    }
    
    
    /**
     This function is to consume a web service using the PUT method
     - Parameter urlString: This is the url to Web Service.
     - Parameter header: `WebServiceHeader`, is the header for request. This value is optional.
     - Parameter parameters: This array containt body's values for request.
     - Parameter completionHandler: Code block who contain web service response
     - Returns: A `URLSessionTask` object
     */
    @discardableResult public func putRequest(urlString : String,
                                              header : MTWebServiceHeaderRequest = MTWebServiceHeaderRequest(),
                                              parameters : [String : Any]?,
                                              completionHandler: @escaping (_ webServiceResponse: MTWebServiceResponse) -> Void) -> URLSessionTask {
        
        return self.webServiceRequest(method: .put, urlString: urlString, header: header, parameters: parameters, completionHandler: completionHandler)
    }
    
    
    /**
     This function is to consume a web service using the DELETE method
     - Parameter urlString: This is the url to Web Service.
     - Parameter header: `WebServiceHeader`, is the header for request. This value is optional.
     - Parameter parameters: This array containt body's values for request.
     - Parameter completionHandler: Code block who contain web service response
     - Returns: A `URLSessionTask` object
     */
    @discardableResult public func deleteRequest(urlString : String,
                                                 header : MTWebServiceHeaderRequest = MTWebServiceHeaderRequest(),
                                                 parameters : [String : Any]?,
                                                 completionHandler: @escaping (_ webServiceResponse: MTWebServiceResponse) -> Void) -> URLSessionTask {
        
        return self.webServiceRequest(method: .delete, urlString: urlString, header: header, parameters: parameters, completionHandler: completionHandler)
    }
    
}

/**
 `WebServiceManager`
 */
public class MTWebServiceManager {
    
    ///  `WebServiceManager`
    public static let shared    = MTWebServiceManager()
    ///  `WebServiceRequest`
    public let request          = MTWebServiceRequest()
}

private extension NSNumber {
    var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

private class SSLSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
