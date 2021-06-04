//
//  URL+extension.swift
//  MTWebServiceManager
//
//  Created by Everis on 5/20/21.
//

import Foundation

extension URL{
    
    init?(networkUri: NetworkUri) {
        self.init(string: networkUri.getUrlString())
    }
}
