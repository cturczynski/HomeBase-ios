//
//  UpdateResult.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 8/5/22.
//

import Foundation

struct UpdateResultJson : Codable {
    var error: String?
    var updateResult: UpdateResult?
}

struct UpdateResult: Codable {
    var affectedRows: Int
    var info: String
    var changedRows: Int?
}
