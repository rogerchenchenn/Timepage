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
    
    private let skipThreshold: CGFloat = 10
    
    var body: some View {
        Group{
            GeometryReader{ fullView in
            ScrollViewReader{ scroll in
                ScrollView(.vertical, showsIndicators: false){
                    LazyVStack{
                        ForEach(-6..<6){ offsetMonth in
                            ScrollView(.vertical, showsIndicators: false, offsetChanged: {self.skipMonth($0, fullHeight: fullView.size.height)} ){
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
                            }.id(offsetMonth)
                                
                            }.frame(width: 300, height: fullView.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        }
                    }
                }.onReceive(pushViewingDate, perform: { offset in
                    print("recieved\(offset)")
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
        let nextAnchor = monthAnchor.offsetMonth - 1
        pushViewingDate.send(nextAnchor)
        DispatchQueue.main.asyncAfter(deadline: .now()+1){
            self.monthAnchor.position = currentPosition.y
            self.isJumping = false
        }
        
    }
    func nextMonth(){
        let nextAnchor = monthAnchor.offsetMonth + 1
        pushViewingDate.send(nextAnchor)
        DispatchQueue.main.asyncAfter(deadline: .now()+1){
            self.monthAnchor.position = currentPosition.y
            self.isJumping = false
        }
    }
    
    func skipMonth(_ point: CGPoint, fullHeight: CGFloat){
        print(point)
        currentPosition = point
        if isJumping {return}
        let delta = monthAnchor.position - point.y
        if delta>skipThreshold{
            print("skip")
            isJumping = true
            let currentMonth = -1 * Int(point.y/fullHeight) - 6
            if delta.isLess(than: 0){
                pushViewingDate.send(currentMonth-1)
            }else{
                pushViewingDate.send(currentMonth+1)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                self.isJumping = false
            }
        }
    }
}

struct MonthlyView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyView().environmentObject(appParameters())
    }
}
