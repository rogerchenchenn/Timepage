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
                            
                            EventDetailBLock(type: .Location, eventID: event.eventIdentifier)
                            EventDetailBLock(type: .Notes, eventID: event.eventIdentifier)
                            EventDetailBLock(type: .URL, eventID: event.eventIdentifier)
                            EventDetailBLock(type: .Availability, eventID: event.eventIdentifier)
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
    
    let type: EKEventDetail
    let eventID: String
    
    @State var content: String? = nil
    @State private var showTextField: Bool = false
    
    var body: some View {
        VStack{
            Text(type.rawValue.uppercased()).font(.title2).fontWeight(.medium).kerning(3)
                .onAppear(){getContent()}
            if !showTextField{
                Text(content ?? "TAP TO ADD").font(.callout).fontWeight(.light).kerning(1).multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }else{
                TextField(type.rawValue.uppercased(), text: Binding.init(get: {content ?? ""}, set: {content = $0}), onCommit: {onCommit()})
                    .textFieldStyle(RoundedBorderTextFieldStyle()).foregroundColor(.black).padding(.horizontal, 20)
                    .frame(maxWidth: 400)
            }
            
            Rectangle().foregroundColor(.black).opacity(0.1).frame(width: 70, height: 1)
        }.padding(.bottom, 10).contentShape(Rectangle()).onTapGesture {
            if type == .Availability{
                switchAvailaBility()
            }else{
                showTextField.toggle()
            }
        }
    }
    
    func onCommit(){
        if let changedEvent = parameters.EventStore.event(withIdentifier: eventID){
            var updatedContent: String? = content
            if content == ""{
                updatedContent = nil
                content = nil
            }
            switch type {
            case .Location:
                changedEvent.location = updatedContent
            case .Notes:
                changedEvent.notes = updatedContent
            case .URL:
                changedEvent.url = URL(string: updatedContent ?? "")
            default:
                showTextField.toggle()
                return
            }
            
            if let _ = try? parameters.EventStore.save(changedEvent, span: .thisEvent){
                print("successfully updated event:(\(eventID)) with new content \(updatedContent)")
            }
        }
        showTextField.toggle()
    }
    func switchAvailaBility() {
        if let changedEvent = parameters.EventStore.event(withIdentifier: eventID){
            if changedEvent.availability == .free{
                changedEvent.availability = .busy
                content = "BUSY"
            }else{
                changedEvent.availability = .free
                content = "FREE"
            }
            if let _ = try? parameters.EventStore.save(changedEvent, span: .thisEvent){
                print("successfully updated event:(\(eventID))")
            }
        }
    }
    func getContent(){
        DispatchQueue.global(qos: .userInteractive).async {
            if let event = parameters.EventStore.event(withIdentifier: eventID){
                var result: String? = ""
                switch type {
                case .Location:
                    result = event.location
                case .Notes:
                    result = event.notes
                case .URL:
                    result = event.url?.absoluteString
                case .Availability:
                    result = getAvailabity(event.availability)?.uppercased()
                }
                DispatchQueue.main.async {
                    content = result
                }
            }
        }
        
    }
    func getAvailabity(_ avail: EKEventAvailability)-> String?{
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
}

enum EKEventDetail:String{
    case Location = "Location", Notes = "Notes", URL = "URL", Availability = "Availability"
}

