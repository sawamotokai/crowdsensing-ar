//
//  tasks.swift
//  ar
//
//  Created by Kai Sawamoto on 2021-06-04.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)


import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let tasks: [Task]
}

// MARK: - Task
struct Task: Codable {
    let id, rewardID, trashbinID: String
    let trashbin: Trashbin
    let reward: Reward

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rewardID = "rewardId"
        case trashbinID = "trashbinId"
        case trashbin, reward
    }
}

// MARK: - Reward
struct Reward: Codable {
    let id, name: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

// MARK: - Trashbin
struct Trashbin: Codable {
    let id: String
    let location: Location

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case location
    }
}

// MARK: - Location
struct Location: Codable {
    let lat, lng: Int
}


