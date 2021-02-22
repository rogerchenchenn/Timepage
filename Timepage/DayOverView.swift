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
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(getDateDiscription(parameters.selectedDate)).font(.title2).fontWeight(.bold).foregroundColor(.white)
                Text(getDateDistance(parameters.selectedDate)).font(.caption).fontWeight(.thin).foregroundColor(.white).opacity(0.8)
            }.padding(.top, 5)
            .padding(.vertical, 5)
            
            VStack{
                ForEach(events, id: \.self){ event in
                    EventBlock(event: event).frame(width:270).offset(x: -10)
                }
            }
        }.onChange(of: parameters.selectedDate, perform: {_ in getEvents()})
        .onAppear(perform: getEvents)
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
            return date.format("EEEE MMMM dd").uppercased()
        }
    }
    
    func getDateDistance(_ dt: Date?)-> String{
        guard let date = dt else {return ""}
        if calendar.isDateInToday(date){
            return ""
        }else if calendar.isDateInTomorrow(date){
            return ""
        }else if calendar.isDateInYesterday(date){
            return ""
        }else{
            let today = calendar.startOfDay(for: Date())
            let target = calendar.startOfDay(for: date)
            let component = calendar.compare(target, to: today, toGranularity: .day)
            let daysApart = component.rawValue
            if daysApart<0{
                return "\(abs(daysApart)) DAYS AGO"
            }else{
                return "\(abs(daysApart)) DAYS FROM TODAY"
            }
        }
    }
    
    func getEvents(){
        guard self.parameters.selectedDate != nil else {
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
