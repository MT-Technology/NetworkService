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

public protocol MTNetworkHeaderProtocol {
    
    func setToken(token: String) -> MTNetworkHeaderProtocol
    
    func setHeaders(headers: [String: Any]) -> MTNetworkHeaderProtocol
    
    func setContentType(contentType: ContentType) -> MTNetworkHeaderProtocol
    
    func getNetworkHeader() -> MTNetworkHeader
    
}

public class MTNetworkHeader {

    var contentType: ContentType
    var headers : [String:Any]
    
    public init() {
        contentType = .none
        headers = [:]
    }
}

public class MTNetworkHeaderGenerator: MTNetworkHeaderProtocol{
    
    private var networkHeader: MTNetworkHeader
    
    public init() {
        networkHeader = MTNetworkHeader()
    }
    
    public func setToken(token: String) -> MTNetworkHeaderProtocol {
        networkHeader.headers["Authorization"] = "Bearer \(token)"
        return self
    }
    
    public func setHeaders(headers: [String : Any]) -> MTNetworkHeaderProtocol {
        
        var iterator = headers.makeIterator()
        while let header = iterator.next() {
            networkHeader.headers[header.key] = header.value
        }
        return self
    }
    
    public func setContentType(contentType: ContentType) -> MTNetworkHeaderProtocol {
        networkHeader.contentType = contentType
        networkHeader.contentType != .none ? networkHeader.headers["Content-Type"] = contentType.rawValue : nil
        return self
    }
    
    public func getNetworkHeader() -> MTNetworkHeader {
        defer {networkHeader = MTNetworkHeader()}
        return networkHeader
    }
}
