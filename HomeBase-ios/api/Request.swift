//
//  Request.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 8/10/22.
//

import Foundation
import UIKit

class Request {
    
    var requestURL : URL
    let apiHelper = ApiHelper(snakeCase: true)
    
    init(requestURL: URL) {
        self.requestURL = requestURL
    }
    
    func saveToDb<T>(obj: T, completion: @escaping(Result<UpdateResult, ApiRequestError>) -> Void) where T : Codable {
        
        var request = apiHelper.createPostRequest(url: requestURL)
        
        do {
            print("Saving obj: \n\(obj)")
            let shiftData = try apiHelper.jsonEncoder.encode(obj)
            request.httpBody = shiftData
        } catch {
            print("ERROR: \n\(error)")
            completion(.failure(.cannotEncodeData(description: error.localizedDescription)))
            return
        }
        
        print("Saving data with request URL: \n\(requestURL)")
        let dataTask = URLSession.shared.dataTask(with: request) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noData(description: "")))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                print("Retrieved update result json: \n\(json!)")
                let updateResultJson = try ApiHelper(snakeCase: false).jsonDecoder.decode(UpdateResultJson.self, from: jsonData)
                
                if updateResultJson.error != nil || updateResultJson.updateResult == nil{
                    completion(.failure(.requestFailed(description: updateResultJson.error ?? "")))
                } else if updateResultJson.updateResult!.affectedRows <= 0 {
                    completion(.failure(.noMatchingResults(description: "")))
                } else {
                    completion(.success(updateResultJson.updateResult!))
                }
            } catch {
                print("ERROR: \n\(error)")
                completion(.failure(.cannotProcessData(description: error.localizedDescription)))
            }
        }
        dataTask.resume()
    }
}
