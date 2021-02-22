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
    @State private var monthAnchor: (position:CGFloat, offsetMonth:Int) = (0,0)
    @State private var currentPosition: CGPoint = .zero
    @State private var isJumping: Bool = false
    @State private var allowedToMove: Bool = true
    @State private var currentOffsetMonth: Int = 0
    
    
    private let skipThreshold: CGFloat = 10
    private let monthSpan: Int = 6
    
    var body: some View {
        Group{
            GeometryReader{ fullView in
                ScrollViewReader{ scroll in
                    ScrollView(.vertical, showsIndicators: false, offsetChanged: {updateCurrentPosiition($0, fullHeight: fullView.size.height)}){
                        LazyVStack(spacing: 0){
                            ForEach(-monthSpan..<monthSpan+1){ offsetMonth in
                                VStack{
                                MonthView(month: getMonth(offsetMonth) ){ date in
                                    calendarItem(date: date)
                                }
                                    
                                }.frame(width: fullView.size.width, height: fullView.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .id(offsetMonth)
                            }
                        }
                        
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
        let offset = -point.y/fullHeight - CGFloat(monthSpan)
//        print("currently at \(Int(offset))")
        currentOffsetMonth = Int(offset)
    }
}

struct MonthlyView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyView().environmentObject(appParameters()).frame(width: 300, height: 1200).background(Color.black)
    }
}

struct calendarItem: View {
    
    @Environment(\.calendar) var calendar
    @EnvironmentObject var parameters: appParameters
    
    let date: Date
    
    var body: some View {
        Text("30")
            .hidden()
            .padding(8)
            .background(parameters.highlightColor)
            .clipShape(Circle())
            .padding(.vertical, 4)
            .overlay(
                Text(String(self.calendar.component(.day, from: date)))
                    .foregroundColor(.white)
            ).onTapGesture {
                self.parameters.selectedDate = date
            }
    }
}
