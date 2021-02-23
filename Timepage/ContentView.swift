//
//  ContentView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI

struct ContentView: View {
    
    @State private var dateOfTruth:Date = Date()
    @State private var showMonthCalendar: Bool = true
    @State private var showDailyView: Bool = true
    @State private var currentOffsetMonth: Int = 0
    
    var body: some View {
        ZStack{
            
            HSplitView{
                if showMonthCalendar{
                    MonthlyView(currentOffsetMonth: $currentOffsetMonth).frame(minWidth: 350, idealWidth: 600, minHeight: 600, idealHeight: 900)
                }
                    
                CalendarListView(currentOffsetMonth: $currentOffsetMonth, showMonthCalendar: $showMonthCalendar)
                    .frame(minWidth: 300, idealWidth: 600, minHeight: 600, idealHeight: 900)
                
            }
            
        }.background(Color.black).ignoresSafeArea().frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(appParameters()).frame(height: 1200)
    }
}
