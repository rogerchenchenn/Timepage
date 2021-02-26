//
//  Structs.swift
//  Timepage
//
//  Created by Roger Chen on 2021/2/19.
//

import Foundation
import SwiftUI
import EventKit

extension Date{
    func format(_ format:String) -> String {
        let timeZone = NSTimeZone.local
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        let date = formatter.string(from: self)
        return date
    }
}

extension Int: VectorArithmetic{
    public mutating func scale(by rhs: Double) {
        self = self*Int(rhs)
    }
    
    public var magnitudeSquared: Double {
        Double(self*self)
    }
    
    
}

extension EKEvent{
    var id: String{
        if let title = self.title{
            return title
        }else{
            return UUID().uuidString
        }
    }
}

extension EKCalendar{
    var isShowing: Bool{
        get{
            UserDefaults().bool(forKey: self.calendarIdentifier)
        }
        set{
            UserDefaults().setValue(newValue, forKey: self.calendarIdentifier)
        }
            
    }
}


public extension View {
    func OnScenePhaseChange(phase: ScenePhase, action: @escaping () -> ()) -> some View
    {
        self.modifier( OnScenePhaseChangeModifier(phase: phase, action: action) )
    }
}

public struct OnScenePhaseChangeModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    
    public let phase: ScenePhase
    
    public let action: () -> ()
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { phase in
                if (phase == phase) {
                    action()
                }
            }
    }
}


//extension Text{
//    func GravesendSans(size : CGFloat)->Text{
//        self
//            .font(.custom("Gravesend Sanss", size: size))
//    }
//}

enum weekDays:String, CaseIterable{
    case Sunday = "SUN"
    case Monday = "MON"
    case Tuesday = "TUE"
    case Wednesday = "WED"
    case Thursday = "THU"
    case Friday = "FRI"
    case Saturday = "SAT"
}
extension Color{
    
}

extension Color {
    var hexString: String{
        if let components = self.cgColor?.components{
            let r = components[0]*255
            let g = components[1]*255
            let b = components[2]*255
            return String(format:"%02X", Int(r)) + String(format:"%02X", Int(g)) + String(format:"%02X", Int(b))
        }else{
            return "FFFFFF"
        }
    }
    
    var colorSpace: String{
        if let cgColor = self.cgColor, let space = cgColor.colorSpace?.name{
            print(space as String)
            return space as String
        }else{
            return "kCGColorSpaceSRGB"
        }
    }
}


extension Color {
    init(hex: String, colorSpace: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        var space: Color.RGBColorSpace = .sRGB
        if colorSpace == "kCGColorSpaceDisplayP3"{
            space = .displayP3
        }
        
        self.init(
            space,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
