//
//  MonthlyView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI
import Combine

var pushViewingDate = PassthroughSubject< Int, Never >()

struct MonthlyView: View {
    
    @Environment(\.calendar) var calendar
    @EnvironmentObject var parameters: appParameters
    
    
    
    @State private var month: Date = Date()
    @Binding var currentOffsetMonth: Int
    @State private var opacityDictionary: [Date:Int] = [:]
    
    
    
    private let skipThreshold: CGFloat = 10
    private let monthSpan: Int = 6
    
    var body: some View {
        Group{
            GeometryReader{ fullView in
                ScrollViewReader{ scroll in
                    ScrollView(.vertical, showsIndicators: false, offsetChanged: {updateCurrentPosiition($0, fullHeight: fullView.size.height)}){
                        LazyVStack(spacing: 0){
                            ForEach(-monthSpan..<monthSpan+1){ offsetMonth in
//                                VStack{
                                MonthView(month: getMonth(offsetMonth) ){ date in
                                    calendarItem(opacityDictionary: $opacityDictionary, date: date)
                                }.onAppear(){getOpacityDictionary()}
                                    
//                                }
                                .frame(width: fullView.size.width, height: fullView.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .id(offsetMonth)
                            }
                        }.onAppear(){scroll.scrollTo(-monthSpan)}
                        
                    }.onReceive(pushViewingDate, perform: { offset in
                        print("recieved\(offset)")
                        withAnimation(.easeInOut(duration: 1)){
                            scroll.scrollTo(offset, anchor: .center)
                        }
                    })
                }
            }
        }
    }
    func getMonth(_ offset: Int)-> Date{
        var component = DateComponents()
        component.month = offset
        if let offsetMonth = calendar.date(byAdding: component, to: month){
            return offsetMonth
        }
        else {return Date()}
    }
    
    func updateCurrentPosiition(_ point: CGPoint , fullHeight: CGFloat){
        let offset = -point.y/fullHeight - CGFloat(monthSpan) + 0.31
//        print("\(offset) \t \(Int(offset.rounded(.down)))")
        currentOffsetMonth = Int(offset.rounded(.down))
//        print("changed offset month to \(currentOffsetMonth)")
    }
    
    func getOpacityDictionary(){
        DispatchQueue.global(qos: .userInteractive).async {
            
            var component1 = DateComponents()
            component1.month = monthSpan
            var component2 = DateComponents()
            component2.month = -monthSpan
            
            if let endTime = calendar.date(byAdding: component1, to: month), let startTime = calendar.date(byAdding: component2, to: month){
                let predicate = parameters.EventStore.predicateForEvents(withStart: startTime, end: endTime, calendars: parameters.supportedCalendars)
                let events = parameters.EventStore.events(matching: predicate)
                
                var opacityDict: [Date:Int] = [:]
                
                for event in events{
                    let date = calendar.startOfDay(for: event.startDate)
                    opacityDict.updateValue((opacityDict[date] ?? 0) + 1, forKey: date)
                }
                DispatchQueue.main.async {
                    opacityDictionary = opacityDict
                }
            }
        }
    }
    
    
}

struct MonthlyView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyView(currentOffsetMonth: Binding.constant(0)).environmentObject(appParameters()).frame(width: 300, height: 400).background(Color.black)
    }
}

struct calendarItem: View {
    
    @Environment(\.calendar) var calendar
    @EnvironmentObject var parameters: appParameters
    
    @Binding var opacityDictionary: [Date:Int]
    
    let date: Date
    @State private var fillOpacity : Double = 0
    @State private var selected: Bool = false
    
    var body: some View {
        
        ZStack{
            Text("30")
                .hidden()
                .padding(10)
                .background( calendar.isDateInToday(date) ? .white : parameters.highlightColor.opacity(getOpacity()))
                .overlay(Circle().stroke(lineWidth: 4).foregroundColor(parameters.highlightColor).opacity(getStroke()))
                .clipShape(Circle())
                .padding(.vertical, 5)
                .overlay(
                    Text(String(self.calendar.component(.day, from: date)))
                        .foregroundColor(calendar.isDateInToday(date) ? parameters.highlightColor : .white)
                ).onTapGesture {
                    self.parameters.selectedDate = date
                }
                .overlay(
                    Circle().stroke(lineWidth: 2.2).foregroundColor(.white)
                            .transition(.asymmetric(insertion: .scale(scale: 1.1), removal: .identity))
                        .scaleEffect(isSelected() ? 1.1 : 1)
                        .opacity(isSelected() ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.3, blendDuration: 1.3))
                )
        }
    }
    func getOpacity()-> Double{
        let num = opacityDictionary[calendar.startOfDay(for: date)]
        return 0.334*Double(num ?? 0)
    }
    func getStroke()->Double{
        if let num = opacityDictionary[calendar.startOfDay(for: date)], !calendar.isDateInToday(date), num > 0{
            return 1
        }else{
            return 0
        }
    }
    func isSelected()-> Bool{
        guard let truth = parameters.selectedDate else { return false }
        return calendar.isDate(truth , equalTo: date, toGranularity: .day)
    }
    
}
