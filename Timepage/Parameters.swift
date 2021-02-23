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
    
    @Published var baseColor: Color = Color.init(.displayP3, red: 82/255, green: 99/255, blue: 105/255, opacity: 1)
    @Published var highlightColor: Color = Color.init(.displayP3, red: 218/255, green: 185/255, blue: 103/255, opacity: 1)
    
    @Published var supportedCalendars:[EKCalendar]
    @Published var isSidebarOpen: Bool = false
    
    @Published var selectedDate: Date? = Date()
    
    @Published var EventStore = EKEventStore()
    
    let timer = Timer.publish(every: 5,tolerance: 1, on: .main, in: .common).autoconnect()
    
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
