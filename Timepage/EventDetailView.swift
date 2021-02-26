//
//  EventDetailView.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/23.
//

import SwiftUI
import EventKit
import MapKit

struct EventDetailView: View {
    @EnvironmentObject var parameters: appParameters
    @Environment(\.calendar) var calendar
    @Namespace private var animation
    
    @Binding var showingSelf: Bool
    @State private var showDeleteAlert: Bool = false
    
    let event: EKEvent
    
    var body: some View {
        ZStack{
            ZStack{
                ZStack{
                    ScrollView(.vertical, showsIndicators: false, offsetChanged: {_ in}){
                        VStack(spacing: 20){
                            
                            Text(event.title).font(.title).fontWeight(.medium)
                                .kerning(1).multilineTextAlignment(.center)
                                .padding(.bottom, 30).padding(.horizontal, 30)
                            VStack{
                                Text(getTimeInterval()).font(.title).fontWeight(.light).kerning(1)
                                Text(event.startDate.format("EEEE MMMM d").uppercased()).font(.body).fontWeight(.light).kerning(1)
                            }
                            
                            Text(event.calendar.title.uppercased()).kerning(1)
                                .font(.body).fontWeight(.thin)
                                .padding(.vertical, 5).padding(.horizontal, 10)
                                .background(ZStack{
                                    Color.init(event.calendar.color)
                                    Color.white.opacity(0.2)
                                }).clipShape(RoundedRectangle(cornerRadius: 5)).padding(.vertical, 10)
                            
                            //map
                            if event.structuredLocation?.geoLocation != nil{
                            Map.init(coordinateRegion: .init(get: {getLocation()}, set: {_ in }), interactionModes: .zoom )
                                .frame(width: 200, height: 200).clipShape(Circle())
                            }
                            
                            EventDetailBLock(Title: "LOCATION", content: event.location)
                            EventDetailBLock(Title: "NOTES", content: event.notes)
                            EventDetailBLock(Title: "URL", content: event.url?.absoluteString)
                            EventDetailBLock(Title: "AVAILABILITY", content: getAvailabity()?.uppercased())
                            HStack{
                                Spacer()
                            }
                            
                        }
                        
                    }.foregroundColor(.white)
                    VStack{
                        HStack{
                            Image(systemName: "arrow.left").contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.default){
                                        showingSelf.toggle()
                                    }
                                }
                            Spacer()
                            Image(systemName: "minus.circle").contentShape(Rectangle())
                                .onTapGesture {
                                    showDeleteAlert.toggle()
                                }.alert(isPresented: $showDeleteAlert, content: {
                                    Alert(title: Text("Delete this Event?"), primaryButton: .destructive(Text("Yes, delete this event"), action: { deleteThisEvent() }) , secondaryButton: .default(Text("Cancel"), action: {}))
                                })
                        }.font(.system(size: 24, weight: .thin )).foregroundColor(.white)
                        Spacer()
                    }
                    
                }
            }.padding(30)
            
            
        }
        //        .transition(.move(edge: .trailing))
        .ignoresSafeArea()
    }
    func getTimeInterval()-> String{
        if event.isAllDay{
            return "ALL DAY"
        }else{
            return "\(event.startDate.format("h:mm a")) - \(event.endDate.format("h:mm a"))"
        }
    }
    func getLocation()-> MKCoordinateRegion{ 
        if let coordinates = event.structuredLocation?.geoLocation{
            let location = MKCoordinateRegion.init(center: .init(latitude: coordinates.coordinate.latitude, longitude: coordinates.coordinate.longitude), span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
            return location
        }else{
            let location = MKCoordinateRegion.init(center: .init(latitude: 19.443, longitude: -155.5039), span: MKCoordinateSpan.init(latitudeDelta: 45, longitudeDelta: 45))
            return location
        }
    }
    func getAvailabity()-> String?{
        let avail = event.availability
        switch avail {
        case .notSupported:
            return "none"
        case .busy:
            return "busy"
        case .free:
            return "free"
        case .tentative:
            return "tentative"
        case .unavailable:
            return "unavailable"
        @unknown default:
            return nil
        }
    }
    
    func deleteThisEvent(){
        if (try? parameters.EventStore.remove(event, span: .thisEvent)) != nil{
            print("\(String(describing: event.title)) deleted")
            showingSelf = false
        }else{
            print("failed to delete \(String(describing: event.title))")
        }
    }
    
    
}

struct EventDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        EventDetailView(showingSelf: Binding.constant(true), event: appParameters().EventStore.event(withIdentifier: "Test")!)
    }
    func event()-> EKEvent{
        let a = EKEvent()
        a.title = "test"
        a.startDate = Date()
        a.endDate = Date().advanced(by: 60*60*3)
        return a
    }
}
struct EventDetailBLock: View {
    
    @EnvironmentObject var parameters: appParameters
    let Title: String
    let content: String?
    @State private var showTextField: Bool = false
//    var event: EKEvent
    
    var body: some View {
        VStack{
            Text(Title).font(.title2).fontWeight(.medium).kerning(3)
            Text(content ?? " - ").font(.callout).fontWeight(.light).kerning(1).multilineTextAlignment(.center)
                .padding(.bottom, 20)
            Rectangle().foregroundColor(.black).opacity(0.1).frame(width: 70, height: 1)
        }.padding(.bottom, 10)
    }
}
