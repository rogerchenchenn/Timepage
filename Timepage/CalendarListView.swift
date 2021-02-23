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
    
    @State private var localMonth: Int = 0
    @Binding var currentOffsetMonth: Int
    @Binding var showMonthCalendar: Bool
    let daySpan: Int = 60
    
    var body: some View {
        Group{
            GeometryReader{ fullView in
            ScrollViewReader{ scroll in
                ZStack{
                HStack(spacing: 0){
                    Text("\(getMonth(currentOffsetMonth).format("MMMM yyyy").uppercased())")
                        .font(.body)
                        .fontWeight(.medium)
                        .kerning(7)
                        .frame(width:400).contentShape(Rectangle())
                        .rotationEffect(.degrees(270))
                        .foregroundColor(parameters.highlightColor).frame(width:30)
                        .animation(.spring()).onTapGesture {
                            withAnimation(.default){
                            showMonthCalendar.toggle()
                            }
                        }
                    ScrollView(showsIndicators: false, offsetChanged: {updateCurrentPosition($0, fullHeight: fullView.size.height)}){
                        LazyVStack(spacing:0){
                            ForEach(-daySpan..<daySpan){ offsetDay in
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
                            pushViewingDate.send(0)
                        }
                    }.frame(width:50, height: 50).padding(.bottom, 20)
                }
                }.onAppear(){
                    withAnimation(.default){
                        scroll.scrollTo(0, anchor: .center)
                        pushViewingDate.send(-6)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            pushViewingDate.send(0)
                        }
                    }
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
    func getMonth(_ offSet: Int)-> Date{
        let offsetDayComponent = DateComponents(month: offSet)
        if let offsettedDay = calendar.date(byAdding: offsetDayComponent, to: Date()){
            return calendar.startOfDay(for: offsettedDay)
        }else{
            return Date()
        }
    }
    func updateCurrentPosition(_ point: CGPoint , fullHeight: CGFloat){
        let distance = -point.y/100 - CGFloat(daySpan)
        let offset = distance + fullHeight/200
//        print("\(offset) \t \(Int(offset.rounded(.down)))")
        let offsetDays = Int(offset.rounded(.down))
        let date = getDay(offsetDays)
        guard let startOfTarget = calendar.dateInterval(of: .month, for: date)?.start else { return }
        guard let startOfThisMonth = calendar.dateInterval(of: .month, for: Date())?.start else { return }
        if let month = calendar.dateComponents([.month], from: startOfThisMonth, to: startOfTarget).month{
//            print(date.format("MM/dd/yyyy") + "\t \(month)")
            if month != localMonth{
                print("from here month = \(month), offset = \(currentOffsetMonth)")
                localMonth = month
                pushViewingDate.send(month)
            }
            
        }
    }
    
    
    
}



struct CalendarListView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarListView(currentOffsetMonth: Binding.constant(0), showMonthCalendar: Binding.constant(false)).environmentObject(appParameters())
    }
}

struct DayView: View {
    @Environment(\.calendar) var calendar
    @EnvironmentObject var parameters: appParameters
    
    let date: Date
    @State var isToday:Bool
    @State private var events: [EKEvent] = []
    @State private var currentIndex: Int = 0
    
    let delayTime: Double = 5
    let timer = Timer.publish(every: 5,tolerance: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        HStack(spacing: 0){
            VStack{
                Text(date.format("E").uppercased()).font(.caption2).opacity(0.8)
                Text(date.format("d")).font(.title2)
            }.foregroundColor(isToday ? parameters.highlightColor : .white)
            .padding(.horizontal, 5)
            .frame(minWidth: 50,maxHeight:.infinity)
            .background(Color.black)
            .onTapGesture {
                currentIndex += 1
            }
            
            if isToday{
                Capsule().frame(width:2).foregroundColor(parameters.highlightColor).offset(x:-1)
            }
            ZStack{
            if !events.isEmpty{
                EventBlock(event: events[Int(currentIndex)]).id(UUID())
                    
            }else{
                Spacer()
            }
            }.animation(.easeInOut(duration: 0.3))
        }
        
        
        .frame(height: 100).background(parameters.baseColor).overlay(VStack{
            Spacer()
            Rectangle().frame(height:0.5).foregroundColor(.black).opacity(0.3)
        })
        .onAppear(perform: getEvents)
        .onReceive(timer){ _ in
//            print("recieved timer")
            if events.count<2{
                timer.upstream.connect().cancel()
                return
            }

            if currentIndex<events.count-1{
                currentIndex += 1
            }else{
                currentIndex = 0
            }
        }
        
        
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
                        currentIndex = 0
                    }
                }
            }
        }
    }
    
}

struct EventBlock: View {
    
    @Environment(\.calendar) var calendar
    @EnvironmentObject var parameters: appParameters
    
    let event: EKEvent
    
    var body: some View{
        HStack(spacing: 5){
            Capsule().frame(width: 5, height: 32).foregroundColor(.init(event.calendar.cgColor))
            VStack(alignment: .leading){
                Text(event.title).font(.title2).fontWeight(.light).lineLimit(1)
                if event.isAllDay{
                    Text("ALL DAY")
                        .fontWeight(.light).font(.caption2)
                }else{
                    HStack(spacing: 0){
                        Group{
                            Text(event.startDate.format("HH:mm a")).fontWeight(.light)
                            Text(" ⟶ ").baselineOffset(2).fontWeight(.light)
                            Text(event.endDate.format("HH:mm a")).fontWeight(.light)
                            
                            if event.location != nil{
                                Text("  \(event.location!)").fontWeight(.light).lineLimit(1)
                            }
                        }
                        .font(.caption2)
                    }
                }
            }.foregroundColor(.white)
            Spacer()
        }
        .padding(.leading, 10)
    }
}
