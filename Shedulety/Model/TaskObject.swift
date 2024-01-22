//
//  TaskObject.swift
//  Shedulety
//
//  Created by Мельник Дмитрий on 21.01.2024.
//

import RealmSwift

class TaskObject: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var descriptionTask: String = ""
    @objc dynamic var dateStart = Date()
    @objc dynamic var dateFinish = Date()
}


