//
//  NetworkResponse.swift
//  NetworkService
//
//  Created by Everis on 5/31/21.
//

import Foundation

public struct MTNetworkResponse {
    
    public var data: Data?
    
    public var headers: [AnyHashable: Any] = [:]
    
    public var statusCode: Int = 0

    init() {
    }
}
