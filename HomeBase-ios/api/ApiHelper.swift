//
//  ApiHelper.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/28/22.
//

import Foundation

public enum ApiRequestError: Error {
    case noData
    case requestFailed
    case cannotProcessData
    case cannotEncodeData
}

class ApiHelper {
    
    let dateFormatter: DateFormatter
    let jsonDecoder: JSONDecoder
    let jsonEncoder: JSONEncoder
    
    init(snakeCase: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        if snakeCase {
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        }
        
        self.dateFormatter = dateFormatter
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
    }
    
    func createPostRequest(url: URL) -> URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}
