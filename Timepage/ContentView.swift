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
            CalendarListView()
        }.frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
