//
//  NetworkProvider.swift
//  MTWebServiceManager
//
//  Created by Everis on 5/20/21.
//

import Foundation

public protocol NetworkProviderProtocol {
    
    func setMethod(method: NetworkMethod) -> NetworkProviderProtocol
    
    func setHeader(header: NetworkHeader) -> NetworkProviderProtocol

    func setParameter(parameters: NetworkParameter) -> NetworkProviderProtocol
    
    func getNetworkProvider() -> NetworkProvider
}

public class NetworkProvider {
    
    let uri: NetworkUri
    var method: NetworkMethod
    var header: NetworkHeader
    var parameters: NetworkParameter
    
    public init (uri: NetworkUri){
        self.uri = uri
        self.method = .get
        self.header = NetworkHeader()
        self.parameters = NetworkParameter(requestType: .none)
    }
    
    @discardableResult
    public func executeTask(completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void ) -> URLSessionTask? {
        Network().networkTask(provider: self, completion: completion)
    }
}

public class NetworkProviderGenerator: NetworkProviderProtocol{
    
    private var networkProvider: NetworkProvider
    public init(uri:NetworkUri){
        networkProvider = NetworkProvider(uri: uri)
    }
    
    public func setMethod(method: NetworkMethod) -> NetworkProviderProtocol {
        networkProvider.method = method
        return self
    }
    
    public func setHeader(header: NetworkHeader) -> NetworkProviderProtocol {
        networkProvider.header = header
        return self
    }
    
    public func setParameter(parameters: NetworkParameter) -> NetworkProviderProtocol {
        networkProvider.parameters = parameters
        return self
    }
    
    public func getNetworkProvider() -> NetworkProvider {
        defer{networkProvider = NetworkProvider(uri: networkProvider.uri)}
        return networkProvider
    }
}
