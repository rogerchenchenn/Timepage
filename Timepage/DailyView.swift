//
//  DailyView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI

struct DailyView: View {
    var body: some View {
        NavigationView{
            DailyViewContent(date: Date()).onTapGesture {
                
            }
            NavigationLink("tap me", destination: DailyViewContent(date: Date().advanced(by: 24*60*60)))
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct DailyView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView()
    }
}

struct DailyViewContent: View {
    let date: Date
    var body: some View {
        ZStack{
            HStack{
                Image(systemName: "xmark")
                VStack(spacing: 0){
                    Text("\(date.format("EEEE").uppercased())").font(.largeTitle).fontWeight(.medium)
                        .kerning(3)
                    Text("\(date.format("MMMM d"))").font(.body).fontWeight(.light)
                }
                Image(systemName: "plus")
            }
        }
    }
}
