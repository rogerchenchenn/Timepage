//
//  ContentView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI

struct ContentView: View {
    
    @State private var dateOfTruth:Date = Date()
    
    var body: some View {
        ZStack{
            HStack{
                MonthlyView()
                CalendarListView()
            }
        }.background(Color.black).ignoresSafeArea().frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(appParameters()).frame(height: 1200)
    }
}
