//
//  GradientLayer.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import Foundation
import UIKit

class GradientLayer: CALayer {
    
    override init(){
        super.init()
    }
    
    init(center:CGPoint,radius:CGFloat,colors:[CGColor]){
        
        self.center = center
        self.radius = radius
        self.colors = colors
        
        super.init()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init()
        
    }
    
    var center = CGPointMake(50,50)
    var radius:CGFloat = 20
    var colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor]
    
    override func drawInContext(ctx: CGContext) {
        
        CGContextSaveGState(ctx)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(colorSpace, colors, [0.0,1.0])
        
        CGContextDrawRadialGradient(ctx, gradient, center, 0.0, center, radius, CGGradientDrawingOptions.init(rawValue: 0))
        
    }
    
}
