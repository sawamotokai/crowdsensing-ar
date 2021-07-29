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


// MARK: - Location
struct Location: Codable {
    let lat, lng: Double
}

struct AssignmentsDTO: Codable {
    let assignments: [Assignment]
}

// MARK: - Assignment
struct Assignment: Codable {
    let id, username, taskID: String
    let isCompleted: Bool
    let assignedTime: String
    let completedTime: JSONNull?
    let isValid: Bool
    let timeLimit: Int
    let task: Task

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, taskID, isCompleted, assignedTime, completedTime, isValid, timeLimit, task
    }
}

// MARK: - Task
struct Task: Codable {
    let id, rewardID, trashbinID: String
    let targetAoI: Int
    let lastUpdateTime: String
    let timeLimit: Int
    let trashbin: Trashbin
    let reward: Reward

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rewardID = "rewardId"
        case trashbinID = "trashbinId"
        case targetAoI, lastUpdateTime, timeLimit, trashbin, reward
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

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
