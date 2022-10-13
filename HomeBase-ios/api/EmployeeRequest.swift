//
//  DataRetriever.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

class EmployeeRequest: Request {
    
    //for SELECT queries
    init(id: Int?, username: String?) {
        var requestString = "\(BASE_URL)/employee"
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
        
        super.init(requestURL: requestURL)
    }
    
    //for UPDATE/CREATE queries
    init(action: String) {
        let requestString = "\(BASE_URL)/employee/\(action)"
        guard let requestURL = URL(string: requestString) else {fatalError()}
        
        super.init(requestURL: requestURL)
    }
    
    func fetchEmployees(completion: @escaping(Result<[Employee], ApiRequestError>) -> Void) {
        
        print("Fetching data with request URL: \n\(requestURL)")
        let dataTask = URLSession.shared.dataTask(with: requestURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noData(description: "")))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                print("Retrieved employee result json: \n\(json!)")
                let employeeResult = try self.apiHelper.jsonDecoder.decode(EmployeeResult.self, from: jsonData)
                
                if employeeResult.error != nil || employeeResult.employees == nil{
                    completion(.failure(.requestFailed(description: employeeResult.error ?? "")))
                } else {
                    completion(.success(employeeResult.employees!))
                }
            } catch {
                completion(.failure(.cannotProcessData(description: error.localizedDescription)))
            }
        }
        dataTask.resume()
    }
}
