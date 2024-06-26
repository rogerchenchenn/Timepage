//
//  DayOverView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/21.
//

import SwiftUI
import EventKit

struct DayOverView: View {
    
    @Environment(\.calendar) var calendar
    @EnvironmentObject var parameters: appParameters
    
    @State private var events: [EKEvent] = []
    let underMonth: Date
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(getDateDiscription(parameters.selectedDate))
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(.white)
                    .kerning(1)
                Text(getDateDistance(parameters.selectedDate))
                    .font(.caption).fontWeight(.medium)
                    .foregroundColor(.white)
                    .kerning(1)
                    .opacity(0.6)
            }.id(getDateDiscription(parameters.selectedDate))
            .padding(.top, 5)
            .padding(.vertical, 5)
//            .opacity(events.isEmpty ? 0 : 1)
            
            VStack{
                ForEach(events, id: \.self){ event in
                    EventBlock(event: event).frame(width:270).offset(x: -10)
                }
            }
        }.onChange(of: parameters.selectedDate, perform: {_ in getEvents()})
        .onAppear(perform: getEvents).opacity(Show())
    }
    
    
    func getDateDiscription(_ dt: Date?)-> String{
        guard let date = dt else {return ""}
        if calendar.isDateInToday(date){
            return "TODAY"
        }else if calendar.isDateInTomorrow(date){
            return "TOMORROW"
        }else if calendar.isDateInYesterday(date){
            return "YESTERDAY"
        }else{
            return date.format("EEEE MMMM d").uppercased()
        }
    }
    
    func getDateDistance(_ dt: Date?)-> String{
        guard let date = dt else {return ""}
        if calendar.isDateInToday(date) || calendar.isDateInTomorrow(date) || calendar.isDateInYesterday(date){
            return ""
        }else{
            let today = calendar.startOfDay(for: Date())
            let target = calendar.startOfDay(for: date)
            let component = calendar.dateComponents( [.day], from: today, to: target)
            guard let daysApart = component.day else {return "0"}
            if daysApart<0{
                return "\(abs(daysApart)) DAYS AGO"
            }else{
                return "\(abs(daysApart)) DAYS FROM TODAY"
            }
        }
    }
    func Show()-> Double{
        guard self.parameters.selectedDate != nil, calendar.isDate(underMonth, equalTo: parameters.selectedDate!, toGranularity: .month) else { return 0 }
        return 1
    }
    
    func getEvents(){
        guard self.parameters.selectedDate != nil, calendar.isDate(underMonth, equalTo: parameters.selectedDate!, toGranularity: .month) else {
            self.events = []
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let date = calendar.startOfDay(for: self.parameters.selectedDate!)
            if let endOfDay = calendar.date(byAdding: components, to: date){
                let predicate = parameters.EventStore.predicateForEvents(withStart: date, end: endOfDay, calendars: parameters.supportedCalendars)
                let events = parameters.EventStore.events(matching: predicate)
                DispatchQueue.main.async {
                    withAnimation(.default){
                        self.events = events
                    }
                }
            }
        }
    }
}

//struct DayOverView_Previews: PreviewProvider {
//    static var previews: some View {
//        DayOverView()
//    }
//}
