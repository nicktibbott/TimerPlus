//
//  TimerObj.swift
//  Infini Timer
//
//  Created by Nick T on 9/1/18.
//  Copyright © 2018 Nick T. All rights reserved.
//

import UIKit

class TimerObj {
    var hoursRemaining: CGFloat!
    var minutesRemaining: CGFloat!
    var secondsRemaining: CGFloat!
    
    var hoursOriginal: CGFloat!
    var minutesOriginal: CGFloat!
    var secondsOriginal: CGFloat!
    
    var name: String!
    
    var startImmediately: Bool = true

    init(hours: CGFloat, minutes: CGFloat, seconds: CGFloat, name: String){
        self.hoursRemaining = hours
        self.hoursOriginal = hours
        
        self.minutesRemaining = minutes
        self.minutesOriginal = minutes
        
        self.secondsRemaining = seconds
        self.secondsOriginal = seconds
        
        self.name = name
    }
    
    init(){}
}
