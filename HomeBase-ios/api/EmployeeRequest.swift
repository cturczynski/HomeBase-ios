//
//  DataRetriever.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation
import UIKit

struct EmployeeRequest {
    
    let requestURL: URL
    let apiHelper = ApiHelper(snakeCase: true)
    
    init(id: Int?, username: String?) {
        var requestString = "http://localhost:3001/employee"
        if (id == nil && username == nil){
            requestString.append("/all")
        } else {
            requestString.append("?")
            if let id = id {
                requestString.append("id=\(id)&")
            }
            if let username = username {
                requestString.append("username=\(username)")
            }
        }
        if requestString.last == "&" {
            requestString.removeLast()
        }
        
        guard let requestURL = URL(string: requestString) else {fatalError()}
        
        self.requestURL = requestURL
    }
    
    init(action: String) {
        let requestString = "http://localhost:3001/employee/\(action)"
        guard let requestURL = URL(string: requestString) else {fatalError()}
        
        self.requestURL = requestURL
    }
    
    func fetchEmployees(completion: @escaping(Result<[Employee], ApiRequestError>) -> Void) {
        
        let dataTask = URLSession.shared.dataTask(with: requestURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                print(json!)
                let employeeResult = try apiHelper.jsonDecoder.decode(EmployeeResult.self, from: jsonData)
                
                if employeeResult.error != nil || employeeResult.employees == nil{
                    completion(.failure(.requestFailed))
                } else {
                    completion(.success(employeeResult.employees!))
                }
            } catch {
                print(error)
                completion(.failure(.cannotProcessData))
            }
        }
        dataTask.resume()
    }
    
    //TODO: save employee object with body for editting profile
    func setEmployee(completion: @escaping(Result<Bool, ApiRequestError>) -> Void) {
        
        var request = apiHelper.createPostRequest(url: requestURL)
        
        do {
            let userData = try apiHelper.jsonEncoder.encode(currentUser)
            request.httpBody = userData
        } catch {
            print(error)
            completion(.failure(.cannotEncodeData))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                print(json!)
                let updateResultJson = try ApiHelper(snakeCase: false).jsonDecoder.decode(UpdateResultJson.self, from: jsonData)
                
                if updateResultJson.error != nil || updateResultJson.updateResult == nil{
                    completion(.failure(.requestFailed))
                } else {
                    completion(.success(updateResultJson.updateResult!.affectedRows > 0))
                }
            } catch {
                print(error)
                completion(.failure(.cannotProcessData))
            }
        }
        dataTask.resume()
    }
    
}
