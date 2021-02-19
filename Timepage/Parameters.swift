//
//  Parameters.swift
//  Color
//
//  Created by Roger Chen on 2021/1/17.
//

import Foundation
import SwiftUI
import Combine
import EventKit

class appParameters: ObservableObject{
    
    @Published var mainColor: CGColor = CGColor.init(red: 129/255, green: 157/255, blue: 142/255, alpha: 1)
    @Published var inputString: String = ""
    @Published var inputMode: colorMode = .Hex
    @Published var pointer:Int = 0
    @Published var supportedCalendars:[EKCalendar]
    
    
    @Published var EventStore = EKEventStore()
    
    init() {
        let store = EKEventStore()
        self.EventStore = store
        store.requestAccess(to: .event) { granted, error in
            if granted{
                print("granted!")
            }else{
                print("failed to get access to calendar")
            }
        }
        let calSet: Set<String> = ["School", "Holidays in Taiwan", "專題", "Life", "Project 16"]
        self.supportedCalendars = store.calendars(for: .event).filter({ calSet.contains($0.title)})
        
    }
}

enum colorMode:CaseIterable{
    case Hex
    case RGB
    case CMYK
}
