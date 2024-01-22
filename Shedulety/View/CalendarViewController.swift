//
//  ViewController.swift
//  Shedulety
//
//  Created by Мельник Дмитрий on 18.01.2024.
//

import UIKit
import EventKit
import EventKitUI
import RealmSwift


class CalendarViewController: DayViewController, EKEventEditViewDelegate {


    private let eventStore = EKEventStore()
    var calendarViewModel: CalendarViewModelProtocol
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shedulety"
        navigationController?.navigationBar.isTranslucent = false
        requestAccessToCalendar()
    }

    init(calendarViewModel: CalendarController) {
        self.calendarViewModel = calendarViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.reloadData()
        }
    }

    var generatedEvents = [EventDescriptor]()

    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { success, error in

        }
    }

    @objc func storeChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadData()
        }
    }

    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        return calendarViewModel.generatedEvents
    }

    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }
        let ekEvent = ckEvent.ekEvent
        ckEvent.setEventDescription(ckEvent.description)
        presentDetailView(ekEvent)
    }

    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()
            if originalEvent === editingEvent {
                presentEditingViewForEvent(editingEvent.ekEvent)

            } else {
                calendarViewModel.generatedEvents.append(editingEvent)

            }
        }
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let editingViewController = EKEventEditViewController()
        editingViewController.event = ekEvent
        editingViewController.editViewDelegate = self
        editingViewController.eventStore = eventStore
        present(editingViewController, animated: true)
    }

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            endEventEditing()
            if action != .canceled {

                if let ekEvent = controller.event {
                    let ekWrapper = EKWrapper(eventKitEvent: ekEvent, description: ekEvent.notes ?? "Notes")
                    ekWrapper.setEventDescription(ekWrapper.description)
                    calendarViewModel.generatedEvents.append(ekWrapper)
                    // Добавляем событие в Realm
                    let taskObject = TaskObject()
                    taskObject.name = ekWrapper.text
                    taskObject.descriptionTask = ekWrapper.description
                    taskObject.dateStart = ekWrapper.startDate
                    taskObject.dateFinish = ekWrapper.endDate
                    calendarViewModel.saveTaskToRealm(taskObject: taskObject)
                }
                DispatchQueue.main.async {
                    self.reloadData()
                }
            }
            controller.dismiss(animated: true)
    }

    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }

    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }

    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        let ekEvent = EKEvent(eventStore: eventStore)

        var oneHourComponents = DateComponents()
        oneHourComponents.hour = 1

        let endDate = calendar.date(byAdding: oneHourComponents, to: date)

        let newEKWrapper = EKWrapper(eventKitEvent: ekEvent, description: "New Event description")
        newEKWrapper.editedEvent = newEKWrapper
        newEKWrapper.startDate = date
        newEKWrapper.endDate = endDate ?? Date()
        newEKWrapper.text = "New Event"
        create(event: newEKWrapper, animated: true)
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    private func presentDetailView(_ ekEvent: EKEvent) {
        let eventViewController = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
    }
}
