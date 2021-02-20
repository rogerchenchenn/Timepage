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
    
    var body: some View {
        Group{
            GeometryReader{ fullView in
            ScrollViewReader{ scroll in
                ScrollView(.vertical, showsIndicators: false){
                    LazyVStack{
                        ForEach(-6..<6){ offsetMonth in
                            MonthView(month: getMonth(offsetMonth) ){ date in
                                Text("30")
                                    .hidden()
                                    .padding(8)
                                    .background(parameters.highlightColor)
                                    .clipShape(Circle())
                                    .padding(.vertical, 4)
                                    .overlay(
                                        Text(String(self.calendar.component(.day, from: date)))
                                            .foregroundColor(.white)
                                    )
                                
                            }.frame(width: 300, height: fullView.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).id(offsetMonth)
                        }
                    }
                }.onReceive(pushViewingDate, perform: { offset in
                    withAnimation(.easeInOut(duration: 10)){
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
    func previousMonth(){
        var component = DateComponents()
        component.month = -1
        if let offset = calendar.date(byAdding: component, to: month){
            withAnimation(.default){
                month = offset
            }
        }
    }
    func nextMonth(){
        var component = DateComponents()
        component.month = 1
        if let offset = calendar.date(byAdding: component, to: month){
            withAnimation(.default){
                month = offset
            }
        }
    }
}

struct MonthlyView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyView().environmentObject(appParameters())
    }
}
