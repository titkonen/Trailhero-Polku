//
//  Formatting.swift
//  MyLocations
//
//  Created by Toni Itkonen on 14.10.2021.
//

import Foundation

struct FormatDisplay {
    
    static func time(_ seconds: Int) -> String {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.hour, .minute, .second]
      formatter.unitsStyle = .positional
      formatter.zeroFormattingBehavior = .pad
      return formatter.string(from: TimeInterval(seconds))!
    }
    
    
    
}
