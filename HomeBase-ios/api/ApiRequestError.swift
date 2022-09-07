//
//  ApiRequestError.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 9/7/22.
//

import Foundation

public enum ApiRequestError: Error {
    case noData(description: String)
    case requestFailed(description: String)
    case cannotProcessData(description: String)
    case cannotEncodeData(description: String)
    case noMatchingResults(description: String)
}
