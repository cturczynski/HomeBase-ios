//
//  DataRetriever.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation
 
enum EmployeeError: Error {
    case noEmployeeData
    case requestFailed
    case cannotProcessData
}

struct EmployeeRequest {
    
    let requestURL: URL
    
    init(id: Int?) {
        var requestString = "http://localhost:3001/employee"
        if let id = id {
            requestString.append("?id=\(id)")
        } else {
            requestString.append("/all")
        }
        guard let requestURL = URL(string: requestString) else {fatalError()}
        
        self.requestURL = requestURL
    }
    
    func fetchEmployees(completion: @escaping(Result<[Employee], EmployeeError>) -> Void) {
        
        let dataTask = URLSession.shared.dataTask(with: requestURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noEmployeeData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                print(json!)
                let jsonDecoder = JSONDecoder()
                let employeeResult = try jsonDecoder.decode(EmployeeResult.self, from: jsonData)
                completion(.success(employeeResult.employees))
            } catch {
                completion(.failure(.cannotProcessData))
            }
        }
        dataTask.resume()
    }
}
