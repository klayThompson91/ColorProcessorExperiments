//
//  UIColor+ClosestColor.swift
//  ColorExtractor
//
//  Created by Abhay Curam on 10/5/16.
//  Copyright © 2016 Abhay Curam. All rights reserved.
//

import Foundation

public class NearestColor : NSObject
{
    public private(set) var deltaE: CGFloat
    public private(set) var color: UIColor
    
    @available(*, unavailable)
    public override init()
    {
        fatalError()
    }
    
    public init(color: UIColor, deltaE: CGFloat)
    {
        self.deltaE = deltaE
        self.color = color
        super.init()
    }
}

public extension UIColor
{
    public func getClosestColor(fromColors: [UIColor]) -> NearestColor?
    {
        var l1: CGFloat = 0, a1: CGFloat = 0, b1: CGFloat = 0
        var l2: CGFloat = 0, a2: CGFloat = 0, b2: CGFloat = 0, alpha: CGFloat = 0
        
        getLightness(&l1, a: &a1, b: &b1, alpha: &alpha)
        
        var minimumDelta: CGFloat = 200
        var closestColor: UIColor? = nil
        var nearestColor: NearestColor? = nil
        
        for color in fromColors {
            color.getLightness(&l2, a: &a2, b: &b2, alpha: &alpha)
            let deltaE = UIColor.deltaEFrom(l1: l1, a1: a1, b1: b1, l2: l2, a2: a2, b2: b2)
            if deltaE < minimumDelta {
                minimumDelta = deltaE
                closestColor = color
            }
        }
        
        
        if let foundColor = closestColor {
            nearestColor = NearestColor(color: foundColor, deltaE: minimumDelta)
        }
        
        return nearestColor
    }
}
