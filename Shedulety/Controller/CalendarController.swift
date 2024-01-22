//
//  CalendarViewModel.swift
//  Shedulety
//
//  Created by Мельник Дмитрий on 21.01.2024.
//

import Foundation
import EventKit
import RealmSwift


protocol CalendarViewModelProtocol {
    func saveTaskToRealm(taskObject: TaskObject)
    var generatedEvents: [EventDescriptor] { get set }
}

class CalendarController: CalendarViewModelProtocol {

    private let eventStore = EKEventStore()
    var generatedEvents = [EventDescriptor]()
    private var calendarService: CalendarServiceProtocol

    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { success, error in
        }
    }

    init() {
        calendarService = CalendarService()
        generatedEvents = calendarService.generatedEvents
    }

    func saveTaskToRealm(taskObject: TaskObject) {
        calendarService.saveTaskToRealm(taskObject: taskObject)
    }
}
