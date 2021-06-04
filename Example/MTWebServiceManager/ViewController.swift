//
//  ViewController.swift
//  MTWebServiceManager
//
//  Created by MT-Technology on 02/07/2019.
//  Copyright (c) 2019 MT-Technology. All rights reserved.
//

import UIKit
import NetworkService

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        testCallWS()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testCallWS(){
        
        
        let uri = NetworkUriGenerator(baseUrl: "https://development-sanfelipe.ws.solera.pe/v5/",endPoint: "userss/sign_in")
            .getNetworkUri()
        
        let header = NetworkHeaderGenerator()
            .setContentType(contentType: .raw)
            .getNetworkHeader()
        
        let param = NetworkParameter(requestType: .parameters(["documentNumber":40973037,
                                                               "password":"0910",
                                                               "token":"",
                                                               "device":"ios"]))
        
        NetworkProviderGenerator(uri: uri)
            .setMethod(method: .post)
            .setHeader(header: header)
            .setParameter(parameters: param)
            .getNetworkProvider()
            .executeTask { (result) in
                switch result {
                case .success(let response):
                    print(response)
                case .failure(let error):
                    print(error)
                }
            }
    }
}
