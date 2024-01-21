//
//  Task.swift
//  Shedulety
//
//  Created by Мельник Дмитрий on 21.01.2024.
//

import Foundation

struct Task: Codable {
  let id: Int
  let dateStart: TimeInterval
  let dateFinish: TimeInterval
  let name: String
  let description: String

  enum CodingKeys: String, CodingKey {
    case id
    case dateStart = "date_start"
    case dateFinish = "date_finish"
    case name
    case description
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    description = try container.decode(String.self, forKey: .description)

    let dateStringStart = try container.decode(String.self, forKey: .dateStart)
    if let timeIntervalStart = TimeInterval(dateStringStart) {
      dateStart = timeIntervalStart
    } else {
      throw DecodingError.dataCorruptedError(forKey: .dateStart, in: container, debugDescription: "Date string does not represent a valid TimeInterval")
    }

    let dateStringFinish = try container.decode(String.self, forKey: .dateFinish)
    if let timeIntervalFinish = TimeInterval(dateStringFinish) {
      dateFinish = timeIntervalFinish
    } else {
      throw DecodingError.dataCorruptedError(forKey: .dateFinish, in: container, debugDescription: "Date string does not represent a valid TimeInterval")
    }
  }
}
