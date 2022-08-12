//
//  ShiftRequest.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

class ShiftRequest: Request{
    
    init(id: Int?, employee: Int?, date: Date?, start: Date?, end: Date?) {
        var requestString = "http://localhost:3001/shift"
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
                requestString.append("date=\"\(dateFormatter.string(from: date))\"&")
            }
            if let start = start {
                requestString.append("start=\"\(dateFormatter.string(from: start))\"&")
            }
            if let end = end {
                requestString.append("end=\"\(dateFormatter.string(from: end))\"")
            }
        }
        if requestString.last == "&" {
            requestString.removeLast()
        }
        
        guard let requestURL = URL(string: requestString) else {fatalError()}
        
        super.init(requestURL: requestURL)
    }
    
    init(action: String) {
        let requestString = "http://localhost:3001/shift/\(action)"
        guard let requestURL = URL(string: requestString) else {fatalError()}
        
        super.init(requestURL: requestURL)
    }
    
    func fetchShifts(completion: @escaping(Result<[Shift], ApiRequestError>) -> Void) {
        
        let dataTask = URLSession.shared.dataTask(with: requestURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                print(json!)
                let shiftResult = try self.apiHelper.jsonDecoder.decode(ShiftResult.self, from: jsonData)
                
                if shiftResult.error != nil || shiftResult.shifts == nil {
                    completion(.failure(.requestFailed))
                } else {
                    completion(.success(shiftResult.shifts!))
                }
            } catch {
                print(error)
                completion(.failure(.cannotProcessData))
            }
        }
        dataTask.resume()
    }
    
    func refreshShifts() async -> [Shift]? {
        do {
            let urlRequest = URLRequest(url: requestURL)
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                print("Error refreshing shifts.")
                return nil
            }
            let shiftResult = try self.apiHelper.jsonDecoder.decode(ShiftResult.self, from: data)
            if shiftResult.error != nil || shiftResult.shifts == nil {
                return nil
            } else {
                return shiftResult.shifts
            }
        } catch {
            print("Error refreshing shifts.")
            return nil
        }
    }
}
