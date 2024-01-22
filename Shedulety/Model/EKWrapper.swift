//
//  EKWrapper.swift
//  Shedulety
//
//  Created by Мельник Дмитрий on 18.01.2024.
//

import UIKit
import EventKit


import UIKit

public final class EKWrapper: EventDescriptor {
    public var startDate: Date {
        get {
            return ekEvent.startDate
        }
        set {
            ekEvent.startDate = newValue
        }
    }
    public var endDate: Date {
        get {
            return ekEvent.endDate
        }
        set {
            ekEvent.endDate = newValue
        }
    }
    public var isAllDay: Bool {
        get {
            return ekEvent.isAllDay
        }
        set {
            ekEvent.isAllDay = newValue
        }
    }
    public var text: String {
        get {
            return ekEvent.title
        }
        set {
            ekEvent.title = newValue
        }
    }
    public var description: String
  public var attributedText: NSAttributedString?
  public var lineBreakMode: NSLineBreakMode?

    public var color: UIColor {
      get {
          UIColor(cgColor: SystemColors.systemBlue.cgColor)
      }
    }
  public var backgroundColor = SystemColors.systemBlue.withAlphaComponent(0.3)
  public var textColor = SystemColors.label
  public var font = UIFont.boldSystemFont(ofSize: 12)
  public var userInfo: Any?
  public weak var editedEvent: EventDescriptor? {
    didSet {
      updateColors()
    }
  }
 
    public private(set) var ekEvent: EKEvent
    public init(eventKitEvent: EKEvent, description: String) {
        self.ekEvent = eventKitEvent
        self.description = description
        updateColors()
    }

  public func makeEditable() -> EKWrapper {
      let clonned = Self(eventKitEvent: ekEvent, description: description)
      clonned.editedEvent = self
      return clonned
  }

    public func setEventDescription(_ newDescription: String) {
            ekEvent.notes = newDescription
        }


  public func commitEditing() {
    guard let edited = editedEvent else {return}
    edited.startDate = startDate
    edited.endDate = endDate
  }

  private func updateColors() {
    (editedEvent != nil) ? applyEditingColors() : applyStandardColors()
  }

  private func applyStandardColors() {
    backgroundColor = color.withAlphaComponent(0.3)
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    textColor = UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
  }

  private func applyEditingColors() {
    backgroundColor = color
    textColor = .white
  }
}
import RealmSwift

class RealmConfigurationManager {
    static let shared = RealmConfigurationManager()

    private init() {
        configureRealm()
    }

    func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    migration.enumerateObjects(ofType: TaskObject.className()) { oldObject, newObject in
                        newObject!["descriptionTask"] = ""
                    }
                }
            })

        Realm.Configuration.defaultConfiguration = config
    }
}
