//
//  Parameters.swift
//  Color
//
//  Created by Roger Chen on 2021/1/17.
//

import Foundation
import SwiftUI
import Combine

class appParameters: ObservableObject{
    
    @Published var mainColor: CGColor = CGColor.init(red: 129/255, green: 157/255, blue: 142/255, alpha: 1)
    @Published var inputString: String = ""
    @Published var inputMode: colorMode = .Hex
    @Published var pointer:Int = 0
}

enum colorMode:CaseIterable{
    case Hex
    case RGB
    case CMYK
}
