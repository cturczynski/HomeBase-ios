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
}

class ApiHelper {
    
    let dateFormatter: DateFormatter
    let jsonDecoder: JSONDecoder
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        self.dateFormatter = dateFormatter
        self.jsonDecoder = jsonDecoder
    }
}
