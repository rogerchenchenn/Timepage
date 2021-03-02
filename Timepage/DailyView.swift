//
//  DailyView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI
import EventKit

struct DailyView: View {
    @EnvironmentObject var parameters: appParameters
    @Environment(\.calendar) var calendar
    @Namespace private var animation
    
    @Binding var showingSelf: Bool
    
    let daySpan = 60
    @Binding var date: Date
    @State private var showEvent: Bool = false
    @State private var selectedEvent: EKEvent? = nil
    @State private var allDayEvents: [EKEvent] = []
    @State private var scheduledEvents: [EKEvent] = []
    
    
    var body: some View {
            ZStack{
                ZStack{
                    ZStack{
                        VStack{
                            HStack(alignment:.center){
                                VStack(spacing: -1){
                                    Text("\(date.format("EEEE").uppercased())").font(.title).fontWeight(.medium)
                                        .kerning(3)
                                    Text("\(date.format("MMMM d"))").font(.callout).fontWeight(.light)
                                        .kerning(1)
                                }.padding(.bottom, 30).foregroundColor(.white)
                                .onChange(of: date, perform: {_ in getEvents()})
                            }.foregroundColor(.white)
                            Spacer()
                            ScrollView(){
                                VStack{
                                if !allDayEvents.isEmpty{
                                    VStack{
                                        Text("ALL DAY").font(.title3).fontWeight(.light).padding(.bottom, 10)
                                        ForEach(allDayEvents, id: \.self){ event in
                                            RoundedEventBlock(event, schedule: false)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.2) ){
                                                    showEvent = true
                                                selectedEvent = event
                                                    }
                                            }
                                        }
                                    }.foregroundColor(.white).padding(.bottom, 40)
                                }
                                
                                if !scheduledEvents.isEmpty{
                                    VStack{
                                        Text("SCHEDULE").font(.title3).fontWeight(.light).padding(.bottom, 10)
                                        ForEach(scheduledEvents, id: \.self){ event in
                                            RoundedEventBlock(event, schedule: true)
                                                .onTapGesture {
                                                    withAnimation(.spring() ){
                                                    showEvent = true
                                                selectedEvent = event
                                                    }
                                            }
                                        }
                                    }.foregroundColor(.white)
                                }
                            }
                            }
                            Spacer()
                        }
                    }
                    
                    VStack{
                        HStack{
                            Image(systemName: "arrow.left").contentShape(Rectangle())
                                .onTapGesture {
                                withAnimation(.default){
                                    showingSelf.toggle()
                                }
                            }
                            Spacer()
                            Image(systemName: "plus").help("This feature hasn't been implemented")
                        }.font(.system(size: 24, weight: .thin )).foregroundColor(.white)
                        Spacer()
                    }
                }.padding(30)
                
                if showEvent && selectedEvent != nil{
                    EventDetailView(showingSelf: $showEvent, event: selectedEvent!).background(
                        Color.init(selectedEvent!.calendar.color)
                        .matchedGeometryEffect(id: "\(selectedEvent!.id)bg", in: animation)
                    )
                }
                
                
            }.background(parameters.baseColor)
            .transition(.move(edge: .trailing))
            .ignoresSafeArea()
    }
    
    func getDay( _ offset: Int)->Date{
        var offsetDayComponent = DateComponents()
        offsetDayComponent.day = offset
        if let offsettedDay = calendar.date(byAdding: offsetDayComponent, to: Date()){
            return calendar.startOfDay(for: offsettedDay)
        }else{
            return Date()
        }
    }
    func getEvents(){
        //        print(date.format("MM-dd-yyyy HH:mm"))
        DispatchQueue.global(qos: .userInteractive).async {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let startOfDay = calendar.startOfDay(for: date)
            if let endOfDay = calendar.date(byAdding: components, to: date){
                let predicate = parameters.EventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: parameters.supportedCalendars)
                let events = parameters.EventStore.events(matching: predicate)
                var allDay: [EKEvent] = []
                var scheduled: [EKEvent] = []
                for event in events{
                    if event.isAllDay{
                        allDay.append(event)
                    }else{
                        scheduled.append(event)
                    }
                }
                DispatchQueue.main.async {
                    withAnimation(.none){
                        self.allDayEvents = allDay
                        self.scheduledEvents = scheduled
                    }
                }
            }
        }
    }
    
    func RoundedEventBlock(_ event: EKEvent, schedule: Bool)-> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20).foregroundColor(Color(event.calendar.color))
                .matchedGeometryEffect(id: "\(event.id)bg", in: animation)
            HStack{
                Spacer()
                VStack{
                    Text(event.title).font(.title).fontWeight(.light).kerning(1).multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    if schedule{
                        HStack(spacing: 0){
                            Text(event.startDate.format("HH:mm a")).fontWeight(.light)
                            Text(" ⟶ ").baselineOffset(2).fontWeight(.light)
                            Text(event.endDate.format("HH:mm a")).fontWeight(.light)
                        }
                    }
                }
                Spacer()
            }
        }.frame(height: 80).frame(maxWidth: 500).animation(.default)
    }
    
}

struct DailyView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView(showingSelf: Binding.constant(true), date: .constant(Date()))
    }
}

struct DailyViewContent: View {
    
    @EnvironmentObject var parameters: appParameters
    @Environment(\.calendar) var calendar
    @Namespace private var animation
    
    @State private var allDayEvents: [EKEvent] = []
    @State private var scheduledEvents: [EKEvent] = []
    
    @Binding var selectedEvent: EKEvent?
    @Binding var showEvent: Bool
    
    let date: Date
    var body: some View {
        ZStack{
            VStack{
                HStack(alignment:.center){
                    VStack(spacing: -1){
                        Text("\(date.format("EEEE").uppercased())").font(.title).fontWeight(.medium)
                            .kerning(3)
                        Text("\(date.format("MMMM d"))").font(.callout).fontWeight(.light)
                            .kerning(1)
                    }.padding(.bottom, 30).foregroundColor(.white)
                    .onAppear(perform: getEvents )
                }.foregroundColor(.white)
                Spacer()
                ScrollView(){
                    if !allDayEvents.isEmpty{
                        VStack{
                            Text("ALL DAY").font(.title3).fontWeight(.light).padding(.bottom, 10)
                            ForEach(allDayEvents, id: \.self){ event in
                                RoundedEventBlock(event, schedule: false)
                                    .onTapGesture {
                                        showEvent = true
                                    selectedEvent = event
                                }
                            }
                        }.foregroundColor(.white).padding(.bottom, 40)
                    }
                    
                    if !scheduledEvents.isEmpty{
                        VStack{
                            Text("SCHEDULE").font(.title3).fontWeight(.light).padding(.bottom, 10)
                            ForEach(scheduledEvents, id: \.self){ event in
                                RoundedEventBlock(event, schedule: true)
                                    .onTapGesture {
                                        showEvent = true
                                    selectedEvent = event
                                }
                            }
                        }.foregroundColor(.white)
                    }
                }
                Spacer()
            }
            //            .padding(15)
        }
    }
    
    func getEvents(){
        //        print(date.format("MM-dd-yyyy HH:mm"))
        DispatchQueue.global(qos: .userInteractive).async {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let startOfDay = calendar.startOfDay(for: date)
            if let endOfDay = calendar.date(byAdding: components, to: date){
                let predicate = parameters.EventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: parameters.supportedCalendars)
                let events = parameters.EventStore.events(matching: predicate)
                var allDay: [EKEvent] = []
                var scheduled: [EKEvent] = []
                for event in events{
                    if event.isAllDay{
                        allDay.append(event)
                    }else{
                        scheduled.append(event)
                    }
                }
                DispatchQueue.main.async {
                    withAnimation(.default){
                        self.allDayEvents = allDay
                        self.scheduledEvents = scheduled
                    }
                }
            }
        }
    }
    
    func RoundedEventBlock(_ event: EKEvent, schedule: Bool)-> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 20).foregroundColor(Color(event.calendar.color))
            HStack{
                Spacer()
                VStack{
                    Text(event.title).font(.title).fontWeight(.light).kerning(1)
                    if schedule{
                        HStack(spacing: 0){
                            Text(event.startDate.format("HH:mm a")).fontWeight(.light)
                            Text(" ⟶ ").baselineOffset(2).fontWeight(.light)
                            Text(event.endDate.format("HH:mm a")).fontWeight(.light)
                        }
                    }
                }
                Spacer()
            }
        }.frame(height: 100)
    }
    
}
