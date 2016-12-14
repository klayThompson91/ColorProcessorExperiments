//
//  UIColor+CIELAB+DeltaE.swift
//  ColorExtractor
//
//  Created by Abhay Curam on 10/5/16.
//  Copyright © 2016 Abhay Curam. All rights reserved.
//

import Foundation

/*
 * This extension uses the Delta E 1994 Algorithm to compute the delta E metric
 * between two colors in the CIELAB color space. Delta E can be used as a measurement
 * of color difference, or it can be used as a parameter in further computations.
 *
 * Delta E 1994: http://www.easyrgb.com/index.php?X=DELT&H=04#text4
 * This method uses the Graphic Arts weight values.
 */
public extension UIColor
{
    public class func deltaEFrom(l1: CGFloat, a1: CGFloat, b1: CGFloat, l2: CGFloat, a2: CGFloat, b2: CGFloat) -> CGFloat
    {
        let DL = l1 - l2
        let DA = a1 - a2
        let DB = b1 - b2
        
        let c1 = sqrt(pow(a1, 2) + pow(b1, 2))
        let c2 = sqrt(pow(a2, 2) + pow(b2, 2))
        let DC = c1 - c2
        
        var DH = pow(DA, 2) + pow(DB, 2) - pow(DC, 2)
        DH = DH < 0 ? 0 : sqrt(DH)
        
        let sl: CGFloat = 1
        let kc: CGFloat = 1
        let kh: CGFloat = 1
        
        let Kl: CGFloat = 1.0
        let K1: CGFloat = 0.045
        let K2: CGFloat = 0.015
        
        let sc = 1.0 + K1*c1
        let sh = 1.0 + K2*c1
        let i = pow((DL/(Kl*sl)), 2) + pow((DC/(kc*sc)), 2) + pow((DH/(kh*sh)), 2)
        return (i < 0) ? 0 : sqrt(i)
    }
}
