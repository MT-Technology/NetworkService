//
//  NetworkProvider.swift
//  MTWebServiceManager
//
//  Created by Everis on 5/20/21.
//

import Foundation

public protocol MTNetworkProviderProtocol {
    
    func setMethod(method: MTNetworkMethod) -> MTNetworkProviderProtocol
    
    func setHeader(header: MTNetworkHeader) -> MTNetworkProviderProtocol

    func setParameter(parameters: MTNetworkParameter) -> MTNetworkProviderProtocol
    
    func getNetworkProvider() -> MTNetworkProvider
}

public class MTNetworkProvider {
    
    let uri: MTNetworkUri
    var method: MTNetworkMethod
    var header: MTNetworkHeader
    var parameters: MTNetworkParameter
        
    public init (uri: MTNetworkUri){
        self.uri = uri
        self.method = .get
        self.header = MTNetworkHeader()
        self.parameters = MTNetworkParameter(requestType: .none)
    }
    
    @discardableResult
    public func executeTask(completion: @escaping (Result<MTNetworkResponse, MTNetworkError>) -> Void ) -> URLSessionTask? {
        MTNetwork().networkTask(provider: self, completion: completion)
    }
}

public class MTNetworkProviderGenerator: MTNetworkProviderProtocol{
    
    private var networkProvider: MTNetworkProvider
    public init(uri:MTNetworkUri){
        networkProvider = MTNetworkProvider(uri: uri)
    }
    
    public func setMethod(method: MTNetworkMethod) -> MTNetworkProviderProtocol {
        networkProvider.method = method
        return self
    }
    
    public func setHeader(header: MTNetworkHeader) -> MTNetworkProviderProtocol {
        networkProvider.header = header
        return self
    }
    
    public func setParameter(parameters: MTNetworkParameter) -> MTNetworkProviderProtocol {
        networkProvider.parameters = parameters
        return self
    }
    
    public func getNetworkProvider() -> MTNetworkProvider {
        defer{networkProvider = MTNetworkProvider(uri: networkProvider.uri)}
        return networkProvider
    }
}
