//
//  NetworkParameter.swift
//  MTWebServiceManager
//
//  Created by Everis on 5/20/21.
//

import Foundation



class MTNetworkBodyData {
    
    private var requestType: RequestType
    private var contentType: ContentType
    
    init(requestType: RequestType, contentType: ContentType) {
        self.requestType = requestType
        self.contentType = contentType
    }
    
    func getBodyData() throws -> Data? {
        
        var requestBody: RequestBodyData
        switch contentType {
        case .raw:
            requestBody = Raw(requestType: requestType)
            break
        case .formData:
            requestBody = FormData(requestType: requestType)
            break
        case .none:
            return nil
        }
        
        do{
            return try requestBody.getBodyData()
        } catch {
            throw error
        }
    }
}

protocol RequestBodyData {
    var requestType: RequestType {get}
    
    func getBodyData() throws -> Data?
}


class Raw: RequestBodyData {
    
    var requestType: RequestType
    
    init(requestType: RequestType){
        self.requestType = requestType
    }
    
    func getBodyData() throws -> Data? {
        
        switch requestType {
        case .none:
            return nil
        case .jsonData(let data):
            return data
        case .parameters(let parameters):
            do{
                return try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            }catch{
                throw MTNetworkError.cantConvertParameters
            }
        }
    }
}

class FormData: RequestBodyData {
    
    var requestType: RequestType
    
    init(requestType: RequestType){
        self.requestType = requestType
    }
    
    func getBodyData() throws -> Data? {
        
        switch requestType {
        case .none:
            return nil
        case .jsonData(_):
            throw MTNetworkError.cantConvertParameters
        case .parameters(let parameters):
            return parseDictionaryToFormData(parameters: parameters)
        }
    }
    
    private func parseDictionaryToFormData(parameters: [String: Any]) -> Data {
        
        var formData = Data()
        let divisor = "--NetworkService.boundary\r\n"
        let ending = "--NetworkService.boundary--\r\n"
        
        for(key, value) in parameters{
            
            formData.append(divisor.data(using: String.Encoding.utf8)!)
            if let image = value as? UIImage {
                
                let image_data = image.pngData()
                
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
    }
}

public enum RequestType {
    
    case jsonData(Data)
    case parameters([String:Any])
    case none
}

public class MTNetworkParameter {
    
    private let requestType: RequestType
    
    public init(requestType: RequestType) {
        self.requestType = requestType
    }
    
    func getBodyData(contentType: ContentType) throws -> Data? {
        
        do{
            return try MTNetworkBodyData(requestType: requestType, contentType: contentType).getBodyData()
        } catch {
            throw error
        }
    }
}
