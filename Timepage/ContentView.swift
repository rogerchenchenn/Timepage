//
//  ContentView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI

struct ContentView: View {
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
        ContentView().environmentObject(appParameters())
    }
}
