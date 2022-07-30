//
//  DataRetriever.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

struct EmployeeRequest {
    
    let requestURL: URL
    
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
    
    func fetchEmployees(completion: @escaping(Result<[Employee], ApiRequestError>) -> Void) {
        
        let dataTask = URLSession.shared.dataTask(with: requestURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                print(json!)
                let employeeResult = try ApiHelper().jsonDecoder.decode(EmployeeResult.self, from: jsonData)
                completion(.success(employeeResult.employees))
            } catch {
                print(error)
                completion(.failure(.cannotProcessData))
            }
        }
        dataTask.resume()
    }
}
