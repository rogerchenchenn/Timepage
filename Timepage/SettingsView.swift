//
//  SettingsView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import SwiftUI
import EventKit

struct SettingsView: View {
    
    @EnvironmentObject var parameters: appParameters
    
    private enum Tabs: Hashable {
        case about, theme, calendars
    }
    
    var body: some View {
        TabView{
            AboutPage()
                .tabItem{Label("About", systemImage: "signature")}
                .tag(Tabs.about)
            ThemeSettings()
                .tabItem{Label("Theme", systemImage: "paintbrush")}
                .tag(Tabs.theme)
            CalendarList()
                .tabItem{Label("Calendars", systemImage: "calendar")}
                .tag(Tabs.calendars)
        }.padding(20)
        .frame(width: 500, height: 400)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct AboutPage: View {
    @Environment(\.openURL) var openURL
    
    @State private var hovering: Bool = false
    var body: some View {
        ScrollView{
        VStack(alignment: .leading){
            Group{
                Text("""
 Please note that this is not the official app for Timepage for macOS, but rather an enthusiast’s project that was created mainly for learning macOS development through mimicking the app.

 There are some features I didn't implement into the app simply because I don't have the need for it, such as creating a new event or adding reminders. Maybe I'll do it someday, new version will be posted on GitHub if I ever decide to implement it.

 A hidden bar is placed in the middle which you drag to change the proportion between heatmap and calendar, click the month indicator to hide heatmap entirely.

 """)
                
                Text("If you want to support the work I'm doing please consider buying me a coffee.").onHover(perform: { hover in
                    hovering = hover
                }).onTapGesture {
                    openURL(URL(string: "https://www.buymeacoffee.com/rogerchenchen")!)
                }.opacity(hovering ? 0.6 : 1).help("https://www.buymeacoffee.com/rogerchenchen")
                
                Text("\nBest regards,\nRoger")

            }.font(.title3)
        }
    }
    }
}

struct ThemeSettings: View {
    
    @EnvironmentObject var parameters: appParameters
    @State private var changed: Bool = false
    
    var body: some View {
        HStack(spacing: 30){
            Circle().frame(width: 100, height: 100).foregroundColor(parameters.baseColor).overlay(Circle().stroke(lineWidth: 2).foregroundColor(parameters.highlightColor).scaleEffect(1.1))
            VStack(alignment: .trailing){
                ColorPicker("Backgroung Color", selection:Binding.init(
                                get: {parameters.baseColor},
                                set: {parameters.baseColor = $0
                                    UserDefaults.standard.setValue($0.hexString, forKeyPath: "baseColor")
                                    UserDefaults.standard.setValue($0.colorSpace, forKey: "baseColorSpace")
                                }), supportsOpacity: false)
                ColorPicker("Accent Color", selection:
                                Binding.init(get: {parameters.highlightColor}, set: {parameters.highlightColor = $0; UserDefaults.standard.setValue($0.hexString, forKeyPath: "highlightColor")
                                    UserDefaults.standard.setValue($0.colorSpace, forKeyPath: "highlightColorSpace")
                                })
                            , supportsOpacity: false)
            }
        }
    }
}

struct CalendarList: View {
    
    @EnvironmentObject var parameters: appParameters
    
    
    @State private var on: Bool = false
    //    @State private var calendarDictionary: [String:Bool] = [:]
    
    var body: some View {
        ZStack{
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading){
                    //                HStack{Spacer()}
                    ForEach(parameters.EventStore.calendars(for: .event), id: \.self){ calendar in
                        calendarSelector(calendar: calendar, showing: calendar.isShowing)
                            .padding(.vertical, 5).padding(.horizontal, 20)
                    }
                }
                //            .onChange(of: calendarDictionary.count, perform: {_ in parameters.updateSupportedCalendar()} )
            }
        }
    }
    //    func getBinding(_ calendar: EKCalendar) -> Binding<Bool>{
    //        Binding(get: {
    //            if let binding = calendarDictionary[calendar.calendarIdentifier]{
    //                return binding
    //            }else {return calendar.isShowing}
    //        }, set: {
    //            calendarDictionary.updateValue($0, forKey: calendar.calendarIdentifier)
    //            calendar.isShowing = $0
    //        })
    //    }
}
struct calendarSelector: View {
    @EnvironmentObject var parameters: appParameters
    var calendar: EKCalendar
    @State var showing: Bool
    @State private var onHover: Bool = false
    var body: some View {
        
        HStack{
            Circle().foregroundColor(.init(calendar.cgColor)).frame(width: 30, height: 30)
                .padding(.trailing, 10)
            Text(calendar.title).kerning(1).opacity(onHover ? 1 : 0.7)
            Spacer()
            ZStack{
                if showing{
                    Image(systemName: "checkmark")
                    
                }
            }.animation(.easeInOut(duration: 0.2))
        }.contentShape(Rectangle())
        .onTapGesture {
            calendar.isShowing.toggle()
            showing = calendar.isShowing
            parameters.updateSupportedCalendar()
        }.onHover(perform: {onHover = $0})
        
    }
}
