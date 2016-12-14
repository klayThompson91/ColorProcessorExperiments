//
//  ColorHistogramFilter.swift
//  WDColorProcessor
//
//  Created by Abhay Curam on 8/13/16.
//  Copyright © 2016 Workday Inc. All rights reserved.
//

import Foundation
import CoreGraphics


/**
 Setting for precision level to use when extracting a color histogram.
 For memory performance ColorProcessor averages and bins colors when computing a histogram.
 
 -Absolute: Absolute precision, highest accuracy higher memory consumption.
 -High: High precision level.
 -Mid: Medium precision level.
 -Low: Lowest precision level, lowest accuracy best memory performance.
 */
@objc public enum ColorAnalysisPrecisionLevel: Int
{
    case Absolute
    case High
    case Mid
    case Low
}

/// A filter to apply to ColorProcessor when extracting a color histogram.
public class ColorHistogramFilter : NSObject
{
    
    /// The interpolation quality you would like ColorProcessor to apply, impacts accuracy and performace.
    public var pixelInterpolationQuality: CGInterpolationQuality
    
    /// A precision level for color analysis.
    public var precisionLevel: ColorAnalysisPrecisionLevel
    
    /**
     Number of colors you would like to return, the default is to apply no limit.
     Setting a value less than or equal to zero applies no limit.
     */
    public var colorCount: NSNumber?
    
    /// A ordering you would like returned. Set to orderedSame if you would like no ordering.
    public var ordering: ComparisonResult
    
    private override convenience init()
    {
        self.init(precisionLevel: .Absolute,
                  pixelInterpolationQuality: .default,
                  colorCount: nil,
                  ordering: .orderedSame)
    }
    
    /**
     Initializes a new ColorHistogramFilter.
     */
    public init(precisionLevel: ColorAnalysisPrecisionLevel,
                pixelInterpolationQuality: CGInterpolationQuality,
                colorCount: NSNumber?,
                ordering: ComparisonResult)
    {
        self.pixelInterpolationQuality = pixelInterpolationQuality
        self.precisionLevel = precisionLevel
        self.colorCount = colorCount
        self.ordering = ordering
        super.init()
    }
    
    /**
     Convenience class methods to return pre-configured HistogramFilters for images with
     different color distributions. All images have unique distributions and variances of colors.
     For example an image of a plain night-sky will have a much smaller color distribution
     than an image of a colorful mosaic or collage.
     */
    public class func defaultImageFilter(colorCount: NSNumber?, ordering: ComparisonResult) -> ColorHistogramFilter
    {
        return filterForLargeColorDistributions(colorCount: colorCount, ordering: ordering)
    }
    
    public class func filterForSmallColorDistributions(colorCount: NSNumber?, ordering: ComparisonResult) -> ColorHistogramFilter
    {
        return ColorHistogramFilter(precisionLevel: .Absolute,
                                    pixelInterpolationQuality: CGInterpolationQuality.medium,
                                    colorCount: colorCount,
                                    ordering: ordering)
    }
    
    public class func filterForMediumColorDistributions(colorCount: NSNumber?, ordering: ComparisonResult) -> ColorHistogramFilter
    {
        return ColorHistogramFilter(precisionLevel: .High,
                                    pixelInterpolationQuality: CGInterpolationQuality.high,
                                    colorCount: colorCount,
                                    ordering: ordering)
    }
    
    public class func filterForLargeColorDistributions(colorCount: NSNumber?, ordering: ComparisonResult) -> ColorHistogramFilter
    {
        return ColorHistogramFilter(precisionLevel: .Mid,
                                    pixelInterpolationQuality: CGInterpolationQuality.high,
                                    colorCount: colorCount,
                                    ordering: ordering)
    }
    
    
}
