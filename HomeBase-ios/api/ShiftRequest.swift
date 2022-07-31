//
//  ShiftRequest.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 7/21/22.
//

import Foundation

struct ShiftRequest {
    
    let requestURL: URL
    let apiHelper = ApiHelper()
    
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
        
        self.requestURL = requestURL
    }
    
    init() {
        let requestString = "http://localhost:3001/shift"
        guard let requestURL = URL(string: requestString) else {fatalError()}
        
        self.requestURL = requestURL
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
                let shiftResult = try apiHelper.jsonDecoder.decode(ShiftResult.self, from: jsonData)
                completion(.success(shiftResult.shifts))
            } catch {
                print(error)
                completion(.failure(.cannotProcessData))
            }
        }
        dataTask.resume()
    }
    
    //TODO: save shift object with body for clocking in/out
    func updateShift(completion: @escaping(Result<Shift, ApiRequestError>) -> Void) {
        
        var request = apiHelper.createPostRequest(url: requestURL)
        
        do {
            let userJson = try ApiHelper.init().jsonEncoder.encode(currentUser)
            let userData = try JSONSerialization.data(withJSONObject: userJson, options: [])
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
                let employeeResult = try apiHelper.jsonDecoder.decode(Shift.self, from: jsonData)
                completion(.success(employeeResult))
            } catch {
                print(error)
                completion(.failure(.cannotProcessData))
            }
        }
        dataTask.resume()
    }
}
