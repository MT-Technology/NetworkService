//
//  NetworkUri.swift
//  MTWebServiceManager
//
//  Created by Everis on 5/23/21.
//

import Foundation


public protocol MTNetworkUriProtocol {
    
    func setQueryParameters(queryParameters: [String:Any]) -> MTNetworkUriProtocol
    
    func getNetworkUri() -> MTNetworkUri
}

public class MTNetworkUri{
    
    var baseUrl: String
    
    var endPoint: String
    
    var queryParameters: String
    
    fileprivate init(baseUrl: String, endPoint: String){
        self.baseUrl = baseUrl
        self.endPoint = endPoint
        queryParameters = ""    
    }
    
    func getUrlString() -> String{
        (baseUrl+endPoint+queryParameters).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

public class MTNetworkUriGenerator: MTNetworkUriProtocol{
    
    private var networkUri: MTNetworkUri
    
    public init(baseUrl: String, endPoint: String) {
        networkUri = MTNetworkUri(baseUrl: baseUrl, endPoint: endPoint)
    }
    
    public func setQueryParameters(queryParameters: [String : Any]) -> MTNetworkUriProtocol {
        
        var queryParameterString = ""
        var paramArray = [String]()
        var iterator = queryParameters.makeIterator()
        while let param = iterator.next() {
            paramArray.append("\(param.key)=\(param.value)")
        }
        queryParameterString = queryParameters.count > 1 ?  "?" + paramArray.joined(separator: "&") : ""
        networkUri.queryParameters = queryParameterString
        return self
        
    }
    
    public func getNetworkUri() -> MTNetworkUri {
        defer {networkUri = MTNetworkUri(baseUrl: networkUri.baseUrl, endPoint: networkUri.endPoint)}
        return networkUri
    }
}
