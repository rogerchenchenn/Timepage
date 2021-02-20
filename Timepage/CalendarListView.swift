//
//  CalendarListView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI
import EventKit

struct CalendarListView: View {
    @EnvironmentObject var parameters: appParameters
    @Environment(\.calendar) var calendar
    
    var body: some View {
        Group{
            ScrollViewReader{ scroll in
                ZStack{
                HStack(spacing: 0){
                    Text("\(Date().format("MMMM yyyy").uppercased())")
//                        .GravesendSans(size: 14)
                        .font(.body)
                        .fontWeight(.medium)
                        .kerning(7)
                        .frame(width:400)
                        .rotationEffect(.degrees(270))
                        .foregroundColor(parameters.highlightColor).frame(width:30)
                    ScrollView(showsIndicators: false){
                        LazyVStack(spacing:0){
                            ForEach(-60..<60){ offsetDay in
                                DayView(date: getDay(offsetDay), isToday: offsetDay==0).id(offsetDay)
                            }
                        }
                    }
                }
                VStack{
                    Spacer()
                    Circle().foregroundColor(parameters.highlightColor).overlay(Image(systemName: "chevron.up").font(.system(size: 30, weight: .thin, design: .default)).foregroundColor(.white)).onTapGesture {
                        withAnimation(.default){
                            scroll.scrollTo(0, anchor: .center)
                            pushViewingDate.send(-1)
                        }
                    }.frame(width:50, height: 50).padding(.bottom, 20)
                }
            }
            }
        }
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
    
    
    
}



struct CalendarListView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarListView().environmentObject(appParameters())
    }
}

struct DayView: View {
    @Environment(\.calendar) var calendar
    @EnvironmentObject var parameters: appParameters
    
    let date: Date
    @State var isToday:Bool
    @State private var events: [EKEvent] = []
    @State private var currentIndex: Int = 0
    
    var body: some View {
        
        return HStack(spacing: 0){
            VStack{
                Text(date.format("E").uppercased()).font(.caption2).opacity(0.8)
                Text(date.format("d")).font(.title2)
            }.foregroundColor(isToday ? parameters.highlightColor : .white)
            .padding(.horizontal, 5)
            .frame(minWidth: 50,maxHeight:.infinity)
            .background(Color.black)
            
            if isToday{
                Capsule().frame(width:2).foregroundColor(parameters.highlightColor).offset(x:-1)
            }
            
            if !events.isEmpty{
                eventBlock
            }else{
                Spacer()
            }
            
        }.frame(height: 100).background(parameters.baseColor).overlay(VStack{
            Spacer()
            Rectangle().frame(height:0.5).foregroundColor(.black).opacity(0.3)
        })
        .onAppear(perform: getEvents)
        
        
    }
    
    var eventBlock: some View{
        HStack(spacing: 5){
            Capsule().frame(width: 6, height: 30).foregroundColor(.init(events[currentIndex].calendar.cgColor))
            VStack(alignment: .leading){
                Text(events[currentIndex].title).font(.title2).fontWeight(.light).lineLimit(1)
                if events[currentIndex].isAllDay{
                    Text("ALL DAY")
                        .fontWeight(.light).font(.caption2)
                }else{
                    HStack(spacing: 0){
                        Group{
                            Text(events[currentIndex].startDate.format("HH:mm a")).fontWeight(.light)
                            Text(" ⟶ ").baselineOffset(2).fontWeight(.light)
                            Text(events[currentIndex].endDate.format("HH:mm a")).fontWeight(.light)
                            
                            if events[currentIndex].location != nil{
                                Text("  \(events[currentIndex].location!)").fontWeight(.light).lineLimit(1)
                            }
                        }
                        .font(.caption2)
                    }
                }
            }.foregroundColor(.white).frame(maxHeight:.infinity)
            Spacer()
        }.padding(.leading, 5)
    }
    
    func getEvents(){
//        print(date.format("MM-dd-yyyy HH:mm"))
        DispatchQueue.global(qos: .userInteractive).async {
            var components = DateComponents()
            components.day = 1
            components.second = -1
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
