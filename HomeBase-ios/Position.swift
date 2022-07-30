//
//  Position.swift
//  HomeBase-ios
//
//  Created by Casey Turczynski on 6/27/22.
//

import Foundation

enum Position: String, CaseIterable, Decodable {
    case bartender = "BARTENDER"
    case barback = "BARBACK"
    case server = "SERVER"
    case manager = "MANAGER"
}
