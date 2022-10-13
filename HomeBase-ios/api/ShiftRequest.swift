//
//  ShiftRequest.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

class ShiftRequest: Request{
    
    //for SELECT queries
    init(id: Int?, employee: Int?, date: Date?, start: Date?, end: Date?) {
        var requestString = "\(BASE_URL)/shift"
        let dateFormatter = createDateFormatter(withFormat: "yyyy-MM-dd")
        
        if (id == nil && employee == nil && date == nil && start == nil && end == nil) {
            requestString.append("/all")
        } else {
            requestString.append("?")
            if let id = id {
                requestString.append("id=\(id)&")
            }
            if let employee = employee {
                requestString.append("employee=\(employee)&")
            }
            if let date = date {
                requestString.append("date='\(dateFormatter.string(from: date))'&")
            }
            if let start = start {
                requestString.append("start='\(dateFormatter.string(from: start))'&")
            }
            if let end = end {
                requestString.append("end='\(dateFormatter.string(from: end))'")
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
        let requestString = "\(BASE_URL)/shift/\(action)"
        guard let requestURL = URL(string: requestString) else {fatalError()}
        
        super.init(requestURL: requestURL)
    }
    
    func fetchShifts(completion: @escaping(Result<[Shift], ApiRequestError>) -> Void) {
        
        print("Fetching data with request URL: \n\(requestURL)")
        let dataTask = URLSession.shared.dataTask(with: requestURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noData(description: "")))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                print("Retrieved shift result json: \n\(json!)")
                let shiftResult = try self.apiHelper.jsonDecoder.decode(ShiftResult.self, from: jsonData)
                
                if shiftResult.error != nil || shiftResult.shifts == nil {
                    completion(.failure(.requestFailed(description: shiftResult.error ?? "")))
                } else {
                    completion(.success(shiftResult.shifts!))
                }
            } catch {
                completion(.failure(.cannotProcessData(description: error.localizedDescription)))
            }
        }
        dataTask.resume()
    }
    
    //a simpler REST call when we don't care about the error types as much
    //also to try out async/await model
    func refreshShifts() async -> [Shift]? {
        do {
            print("Fetching data with request URL: \n\(requestURL)")
            let urlRequest = URLRequest(url: requestURL)
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                print("Error refreshing shifts.")
                return nil
            }
            let shiftResult = try self.apiHelper.jsonDecoder.decode(ShiftResult.self, from: data)
            print("Retrieved shift result: \n\(shiftResult)")
            if shiftResult.error != nil || shiftResult.shifts == nil {
                return nil
            } else {
                return shiftResult.shifts
            }
        } catch {
            print("ERROR refreshing shifts.")
            return nil
        }
    }
}
