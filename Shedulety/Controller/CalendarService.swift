//
//  CalendarService.swift
//  Shedulety
//
//  Created by Мельник Дмитрий on 22.01.2024.
//

import Foundation
import EventKit
import RealmSwift


protocol CalendarServiceProtocol {
    func getDeskriptors()
    func parsingFromJsonTasks()
    func recieveTasksFromRealm()
    func saveTasksToRealm(tasks: [Task])
    func saveTaskToRealm(taskObject: TaskObject)
    func getTasksFromRealm() -> [TaskObject]

    var generatedEvents: [EventDescriptor] { get set }
}

class CalendarService: CalendarServiceProtocol {

    private let eventStore = EKEventStore()
    var generatedEvents = [EventDescriptor]()

    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { success, error in

        }
    }

    init() {
        RealmConfigurationManager.shared.configureRealm()
        requestAccessToCalendar()
        getDeskriptors()
    }

    func getDeskriptors() {
        let realmTasks = getTasksFromRealm()
        if realmTasks.isEmpty {
            parsingFromJsonTasks()

        } else {
            recieveTasksFromRealm()
        }
    }

    func parsingFromJsonTasks() {
        if let url = Bundle.main.url(forResource: "tasksTwo", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let tasks = try JSONDecoder().decode([Task].self, from: data)

                saveTasksToRealm(tasks: tasks)

                let calendarEvents = tasks.map { task -> EventDescriptor in
                    let ekEvent = EKEvent(eventStore: eventStore)
                    ekEvent.startDate = Date(timeIntervalSince1970: task.dateStart)
                    ekEvent.endDate = Date(timeIntervalSince1970: task.dateFinish)
                    ekEvent.title = task.name
                    let ckEvent = EKWrapper(eventKitEvent: ekEvent, description: task.description)
                    return ckEvent
                }

                generatedEvents.append(contentsOf: calendarEvents)
            } catch {
                print("Error: \(error)")
            }
        } else {
            print("file realm is not exist")
        }
    }

    func recieveTasksFromRealm() {
        let realmTasks = getTasksFromRealm()
        let calendarEvents = realmTasks.map { task -> EventDescriptor in
            let ekEvent = EKEvent(eventStore: eventStore)
            ekEvent.startDate = task.dateStart
            ekEvent.endDate = task.dateFinish
            ekEvent.title = task.name

            let ckEvent = EKWrapper(eventKitEvent: ekEvent, description: task.descriptionTask )
            ckEvent.setEventDescription(ckEvent.description)
            return ckEvent
        }
        generatedEvents.append(contentsOf: calendarEvents)
    }

    func saveTasksToRealm(tasks: [Task]) {
        do {
            let realm = try Realm()
            let existingTasks = realm.objects(TaskObject.self)

            if existingTasks.isEmpty {
                try realm.write {
                    for task in tasks {
                        let taskObject = TaskObject()
                        taskObject.name = task.name
                        taskObject.descriptionTask = task.description
                        taskObject.dateStart = Date(timeIntervalSince1970: task.dateStart)
                        taskObject.dateFinish = Date(timeIntervalSince1970: task.dateFinish)
                        realm.add(taskObject)
                    }
                }
            } else {
                print("Tasks already exist in Realm. No need to save them again.")
            }
        } catch {
            print("Error saving tasks to Realm: \(error)")
        }
    }


    func saveTaskToRealm(taskObject: TaskObject) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(taskObject)
            }
        } catch {
            print("Error saving task to Realm: \(error)")
        }
    }


    func getTasksFromRealm() -> [TaskObject] {
        do {
            let realm = try Realm()
            return Array(realm.objects(TaskObject.self))
        } catch {
            print("Error retrieving tasks from Realm: \(error)")
            return []
        }
    }
}
