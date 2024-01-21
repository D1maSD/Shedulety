//
//  CalendarViewModel.swift
//  Shedulety
//
//  Created by Мельник Дмитрий on 21.01.2024.
//

import Foundation
import EventKit
import RealmSwift


class CalendarViewModel {

    private let eventStore = EKEventStore()
    var generatedEvents = [EventDescriptor]()

    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { success, error in

        }
    }

    init() {
        print("25 .init CalendarViewModel")
        requestAccessToCalendar()
        getDeskriptors()
    }

    func getDeskriptors() {
        let realmTasks = getTasksFromRealm()
        if realmTasks.isEmpty {
            print("if realmTasks.isEmpty")
            if let url = Bundle.main.url(forResource: "tasksTwo", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let tasks = try JSONDecoder().decode([Task].self, from: data)

                    saveTasksToRealm(tasks: tasks) // Сохраняем полученные данные в Realm

                    let calendarEvents = tasks.map { task -> EventDescriptor in
                        let ekEvent = EKEvent(eventStore: eventStore)
                        // Используем eventStore для создания EKEvent
                        ekEvent.startDate = Date(timeIntervalSince1970: task.dateStart)
                        ekEvent.endDate = Date(timeIntervalSince1970: task.dateFinish)
                        ekEvent.title = task.name
                        let ckEvent = EKWrapper(eventKitEvent: ekEvent)
                        return ckEvent
                    }
                    print("25 .getDeskriptors")
                    for event in calendarEvents {
                        print("event startDate: \(event.startDate) endDate: \(event.endDate)")
                    }
                    generatedEvents.append(contentsOf: calendarEvents)
                } catch {
                    print("Error: \(error)")
                }
            } else {
                print("file realm is not exist")
                // Обработка случая, когда файл не найден
            }
        } else {
            print("25 .else realmTasks.isEmpty")
            // Используем данные из Realm
            let calendarEvents = realmTasks.map { task -> EventDescriptor in
                let ekEvent = EKEvent(eventStore: eventStore)
                ekEvent.startDate = task.dateStart
                ekEvent.endDate = task.dateFinish
                ekEvent.title = task.name
                let ckEvent = EKWrapper(eventKitEvent: ekEvent)
                return ckEvent
            }
            generatedEvents.append(contentsOf: calendarEvents)
        }
    }
    
    func saveTasksToRealm(tasks: [Task]) {
        do {
            let realm = try Realm()
            try realm.write {
                for task in tasks {
                    let taskObject = TaskObject()
                    taskObject.name = task.name
                    taskObject.dateStart = Date(timeIntervalSince1970: task.dateStart)
                    taskObject.dateFinish = Date(timeIntervalSince1970: task.dateFinish)
                    realm.add(taskObject)
                }
            }
        } catch {
            print("Error saving tasks to Realm: \(error)")
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
