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


    //EKEventEditViewDelegate need to edit created events (on creating moment)
    private let eventStore = EKEventStore()
    var calendarViewModel = CalendarViewModel()
    override func viewDidLoad() {
        print("1: viewDidLoad")
        super.viewDidLoad()
//        getDeskriptors()
        title = "Calendar"
        requestAccessToCalendar()
    }

    init(calendarViewModel: CalendarViewModel) {
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

    // запрашиваем доступ к календарю
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { success, error in

        }
    }

// we reload data when we get a new infromation from calendar
    @objc func storeChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadData()
        }
    }


    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        print("2: eventsForDate")

        return calendarViewModel.generatedEvents
    }

    override func dayViewDidSelectEventView(_ eventView: EventView) {
        print("3: dayViewDidSelectEventView")
        print("dayViewDidSelectEventView: \(eventView)")
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }
        let ekEvent = ckEvent.ekEvent
        presentDetailView(ekEvent)
    }

    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        print("6: didUpdate")
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()
            print("6.1: didUpdate save")
            if originalEvent === editingEvent {
                print("6.2: didUpdate save")
                presentEditingViewForEvent(editingEvent.ekEvent)

            } else {
                print("6.3: didUpdate save")
                calendarViewModel.generatedEvents.append(editingEvent)

            }
        }
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        print("8: presentEditingViewForEvent")
        let editingViewController = EKEventEditViewController()
        editingViewController.event = ekEvent
        editingViewController.editViewDelegate = self
        editingViewController.eventStore = eventStore
        present(editingViewController, animated: true)
    }

    //EKEventEditViewDelegate need to edit created events (on creating moment)
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {

        print("7: eventEditViewController")
            endEventEditing()
            if action != .canceled {
                // Добавляем созданный ивент из контроллера редактирования в массив generatedEvents
                if let ekEvent = controller.event {
                    let ekWrapper = EKWrapper(eventKitEvent: ekEvent)
                    calendarViewModel.generatedEvents.append(ekWrapper)
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

        let newEKWrapper = EKWrapper(eventKitEvent: ekEvent)
        newEKWrapper.editedEvent = newEKWrapper
        newEKWrapper.startDate = date
        newEKWrapper.endDate = endDate ?? Date()
        newEKWrapper.text = "New Event"
        calendarViewModel.generatedEvents.append(newEKWrapper)

        create(event: newEKWrapper, animated: true)
    }

    private func presentDetailView(_ ekEvent: EKEvent) {
        let eventViewController = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
        print("Event clicked")
    }
///////////FROM REALM
}
