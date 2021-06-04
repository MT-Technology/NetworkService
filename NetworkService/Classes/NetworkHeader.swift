//
//  NetworkHeader.swift
//  MTWebServiceManager
//
//  Created by Everis on 5/23/21.
//

import Foundation

public enum ContentType: String{
    
    
    case formData   = "multipart/form-data; boundary=NetworkService.boundary"
    
    case raw        = "application/json"
        
    case none       = ""
}

public protocol NetworkHeaderProtocol {
    
    func setToken(token: String) -> NetworkHeaderProtocol
    
    func setHeaders(headers: [String: Any]) -> NetworkHeaderProtocol
    
    func setContentType(contentType: ContentType) -> NetworkHeaderProtocol
    
    func getNetworkHeader() -> NetworkHeader
    
}

public class NetworkHeader {

    var contentType: ContentType
    var headers : [String:Any]
    
    public init() {
        contentType = .none
        headers = [:]
    }
}

public class NetworkHeaderGenerator: NetworkHeaderProtocol{
    
    private var networkHeader: NetworkHeader
    
    public init() {
        networkHeader = NetworkHeader()
    }
    
    public func setToken(token: String) -> NetworkHeaderProtocol {
        networkHeader.headers["Authorization"] = "Bearer \(token)"
        return self
    }
    
    public func setHeaders(headers: [String : Any]) -> NetworkHeaderProtocol {
        
        var iterator = headers.makeIterator()
        while let header = iterator.next() {
            networkHeader.headers[header.key] = header.value
        }
        return self
    }
    
    public func setContentType(contentType: ContentType) -> NetworkHeaderProtocol {
        networkHeader.contentType = contentType
        networkHeader.contentType != .none ? networkHeader.headers["Content-Type"] = contentType.rawValue : nil
        return self
    }
    
    public func getNetworkHeader() -> NetworkHeader {
        defer {networkHeader = NetworkHeader()}
        return networkHeader
    }
}
