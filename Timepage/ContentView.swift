//
//  ContentView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @State private var dateOfTruth:Date = Date()
    @State private var showMonthCalendar: Bool = true
    @State private var showDailyView: Bool = true
    @State private var currentOffsetMonth: Int = 0
    
    @State private var pushViewingDate = PassthroughSubject< Int, Never >()
    
    
    var body: some View {
        ZStack{
            
            HSplitView{
                if showMonthCalendar{
                    MonthlyView(currentOffsetMonth: $currentOffsetMonth, pushViewingDate: $pushViewingDate)
                        .frame(minWidth: 350, idealWidth: 500, minHeight: 600, idealHeight: 900)
                }
                
                    
                CalendarListView(currentOffsetMonth: $currentOffsetMonth, showMonthCalendar: $showMonthCalendar, pushViewingDate: $pushViewingDate).ignoresSafeArea()
                    .frame(minWidth: 300, idealWidth: 700, minHeight: 600, idealHeight: 900)
                
            }
            
        }.background(Color.black).ignoresSafeArea().frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(appParameters()).frame(height: 1200)
    }
}
