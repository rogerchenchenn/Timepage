//
//  ContentView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI

struct ContentView: View {
    
    @State private var dateOfTruth:Date = Date()
    @State private var show: Bool = false
    @State private var currentOffsetMonth: Int = 0
    
    var body: some View {
        ZStack{
            HStack{
                MonthlyView(currentOffsetMonth: $currentOffsetMonth)
                CalendarListView(currentOffsetMonth: $currentOffsetMonth)
            }
            
        }.background(Color.black).ignoresSafeArea().frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(appParameters()).frame(height: 1200)
    }
}
