//
//  NetworkError.swift
//  MTWebServiceManager
//
//  Created by Everis on 5/20/21.
//

import Foundation

public enum MTNetworkError: Error{
    
    case wrongUrl
    case cantConvertParameters
    case serverError(code: Int, message: String)
    case genericError
}

extension MTNetworkError: LocalizedError {
    public var localizedDescription: String?{
        switch self {
        case .wrongUrl:
            return "The url is invalid."
        case .cantConvertParameters:
            return "Can't convert parameters."
        case .genericError:
            return "We have a problem, try again."
        case .serverError(_, let message):
            return message
        }
    }
    
    public var errorCode: Int {
        switch self {
        case .wrongUrl:
            return 400
        case .cantConvertParameters:
            return 415
        case .genericError:
            return 00
        case .serverError(let code,_):
            return code
        }
    }
}


