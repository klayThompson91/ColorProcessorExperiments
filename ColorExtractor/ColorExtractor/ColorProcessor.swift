//
//  UIImage+ColorAnalysis.swift
//  WDColorProcessor
//
//  Created by Abhay Curam on 5/13/16.
//  Copyright © 2016 Workday Inc. All rights reserved.
//

import Foundation
import CoreImage
import CoreGraphics
import UIKit

// MARK: Constants
let pixelBoundary = 300
let dataBytesPerPixel:Int = 4
let colorChannel:CGFloat = 255.0
let bitsPerComponent = 8
let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo:UInt32 = (CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
let defaultFilter:ColorHistogramFilter = ColorHistogramFilter.defaultImageFilter(colorCount: nil, ordering: .orderedSame)

public class CountedColor : NSObject
{
    public private(set) var count: Int
    public private(set) var color: UIColor
    
    @available(*, unavailable)
    public override init()
    {
        fatalError()
    }
    
    public init(color: UIColor, colorCount: Int)
    {
        self.count = colorCount
        self.color = color
        super.init()
    }
}

/**
 A ColorProcessor object processes an image and responds to image color queries.
 Can be used to get color information and data at the image and pixel levels.
 */
public class ColorProcessor : NSObject
{
    // MARK: Properties
    
    private typealias ColorBinPallete = (binRange:Int, colorBinMap:Dictionary<Int, Int>)
    private typealias FilterCounts = (binCount:Int, frequencyCount:Int?)
    
    /// The image for ColorProcessor to process.
    public var image: UIImage
    
    internal var imageRect: CGRect {
        return self.image.boundingRectForImageAnalysis
    }
    
    // MARK: Initialization
    
    @available(*, unavailable)
    public override init()
    {
        fatalError()
    }
    
    /**
     Default initializer for ColorProcessor.
     - Parameter image: The image for ColorProcessor to process.
     */
    public init(image: UIImage)
    {
        self.image = image
        super.init()
    }
    
    
    // MARK: Public Methods
    
    /**
     Query color information for an image at a given pixel coordinate.
     - Parameter pixelCoordinate: The pixel coordinate on the image for ColorProcessor to analyze.
     */
    public func queryColorAtPixel(pixelCoordinate: CGPoint) -> UIColor? {
        let point = getPointForPixelCoordinate(pixelCoordinate: pixelCoordinate)
        if let pixelPoint = point, let cgImage = self.image.cgImage {
            var pixelData = [CUnsignedChar](repeating:0, count:4)
            let context = CGContext(data: &pixelData,
                                    width: 1,
                                    height: 1,
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: dataBytesPerPixel,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo);
            
            if let graphicsContext = context {
                graphicsContext.setBlendMode(.copy);
                graphicsContext.interpolationQuality = CGInterpolationQuality.high
                graphicsContext.translateBy(x: -pixelPoint.x, y: pixelPoint.y - self.image.imageHeight + 1);
                graphicsContext.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: self.image.imageWidth, height: self.image.imageHeight));
                return constructColor(imageData: &pixelData, pixelIndex: 0)
            }
        }
        
        return nil;
    }
    
    /**
     Leverage this API to get complete information on every color occurring in a UIImage
     and the frequency at which each color occurs. Optimized for memory and runtime performance.
     
     - Parameter filter: A filter for ColorProcessor to apply during processing. Through the filter
     one can define things like precision levels and sort orderings to filter/modify the returned result set.
     
     - Returns: An array of CountedColor objects. A CountedColor contains a UIColor object and a count value
     indicating how many times the color was found in the image.
     */
    public func extractColorHistogram(filter: ColorHistogramFilter = defaultFilter) -> [CountedColor]
    {
        let colorRange = Double(256/(binCount(filter: filter)))
        let capacity = Int(pow(colorRange, 3))
        let colorInfo = NSCountedSet()
        var pixelData = [CUnsignedChar](repeating:0, count:self.image.totalPixelsInBytes)
        
        var startTime = CACurrentMediaTime()
        var endTime = CACurrentMediaTime()
        
        pixelData = [CUnsignedChar](repeating:0, count:self.image.totalPixelsInBytes)
        let context = CGContext(data: &pixelData,
                                width: Int(self.image.rescaledImageWidth),
                                height: Int(self.image.rescaledImageHeight),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: self.image.bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo);
        
        if let graphicsContext = context, let cgImage = self.image.cgImage {
            
            graphicsContext.setBlendMode(.copy);
            graphicsContext.interpolationQuality = filter.pixelInterpolationQuality
            graphicsContext.draw(cgImage, in: self.image.boundingRectForImageAnalysis)
            
            startTime = CACurrentMediaTime()
            var colorBinSpectrum = generateColorBinSpectrum(binRange: Int(binCount(filter: filter)))
            for h in 0..<Int(self.image.rescaledImageHeight) {
                for w in 0..<Int(self.image.rescaledImageWidth) {
                    let pixel = CGPoint(x: CGFloat(w), y: CGFloat(h))
                    let pixelIndex = self.image.byteLocationForPixel(pixelCoordinate: pixel)
                    let colorKey = constructColor(imageData: &pixelData, pixelIndex: pixelIndex)
                    let closestColor = getClosestColor(randomColor: colorKey, colorBins: &colorBinSpectrum)
                    colorInfo.add(closestColor)
                }
            }
            endTime = CACurrentMediaTime()
            print("Time to generate a histogram of colors: \(endTime - startTime)")
            
        }
        
        
        //The dictionary with a value array code is here
        let numColors = colorCount(filter: filter, colorInfoCount: colorInfo.count)
        var colorCountsArray: [Int] = [Int]()
        var countToColorMap: [Int:[CountedColor]] = [Int:[CountedColor]](minimumCapacity: capacity)
        var topColors = [CountedColor]()
        
        startTime = CACurrentMediaTime()
        let colorInfoColors = colorInfo.allObjects
        for color in colorInfoColors {
            let colorCount = colorInfo.count(for: color)
            colorCountsArray.append(colorCount)
            if countToColorMap[colorCount] != nil {
                countToColorMap[colorCount]?.append(CountedColor(color: color as! UIColor, colorCount: colorCount))
            } else {
                countToColorMap[colorCount] = [CountedColor(color: color as! UIColor, colorCount: colorCount)]
            }
        }
        endTime = CACurrentMediaTime()
        print("Time to create a dictionary with value array: \(endTime - startTime)")
        //The dictionary with a value array code ends here
        
        startTime = CACurrentMediaTime()
        switch filter.ordering {
        case .orderedAscending:
            colorCountsArray.sort(by: <)
        case .orderedDescending:
            colorCountsArray.sort(by: >)
        default:
            break
        }
        endTime = CACurrentMediaTime()
        print("Time to perform sort of array: \(endTime - startTime)")
        
        var lastCount = -1
        for count in colorCountsArray {
            guard count != lastCount else {
                continue
            }
            if let colors = countToColorMap[count] {
                lastCount = count
                if (topColors.count + colors.count) < numColors {
                    topColors.append(contentsOf: (colors))
                } else {
                    var index = 0
                    while topColors.count < numColors {
                        topColors.append(colors[index])
                        index += 1
                    }
                    break
                }
            }
        }
        
        return topColors
        
    }
    
    
    // MARK: Private Helper Methods
    
    private func generateColorBinSpectrum(binRange:Int) -> ColorBinPallete {
        var colorBinMap = Dictionary<Int, Int>()
        var startingBound = 0
        let loopBound = (256 / binRange) + 1
        let rgbRange = (0, 255)
        for i in 1..<loopBound {
            let binIndex = i - 1
            let offset = (startingBound + binRange - startingBound)/2
            let binValue = startingBound + offset
            startingBound += binRange
            if (binIndex == 0 || binIndex == loopBound - 2) {
                colorBinMap[binIndex] = (binIndex == 0) ? rgbRange.0 : rgbRange.1
            } else {
                colorBinMap[binIndex] = binValue
            }
        }
        
        return (binRange, colorBinMap)
    }
    
    private func getClosestColor(randomColor:UIColor, colorBins:inout ColorBinPallete) -> UIColor {
        var returnedRed:CGFloat = 0
        var returnedGreen:CGFloat = 0
        var returnedBlue:CGFloat = 0
        var returnedAlpha:CGFloat = 0
        
        
        
        randomColor.getRed(&returnedRed, green: &returnedGreen, blue: &returnedBlue, alpha: &returnedAlpha)
        return UIColor(red: closestRGB(rgbComponent: returnedRed, colorBins: &colorBins),
                       green: closestRGB(rgbComponent: returnedGreen, colorBins: &colorBins),
                       blue: closestRGB(rgbComponent: returnedBlue, colorBins: &colorBins),
                       alpha: returnedAlpha)
    }
    
    private func closestRGB(rgbComponent:CGFloat, colorBins:inout ColorBinPallete) -> CGFloat {
        return CGFloat(colorBins.colorBinMap[Int((rgbComponent * 255)/CGFloat(colorBins.binRange))]!) / 255.0
    }
    
    private func constructColor( imageData:inout [CUnsignedChar], pixelIndex:Int) -> UIColor {
        let red:CGFloat   = CGFloat((imageData)[pixelIndex]) / colorChannel;
        let green:CGFloat = CGFloat((imageData)[pixelIndex + 1]) / colorChannel;
        let blue:CGFloat  = CGFloat((imageData)[pixelIndex + 2]) / colorChannel;
        let alpha:CGFloat = CGFloat((imageData)[pixelIndex + 3]) / colorChannel;
        return UIColor(red: red, green: green, blue: blue, alpha: alpha);
    }
    
    private func getPointForPixelCoordinate(pixelCoordinate:CGPoint) -> CGPoint? {
        if !CGRect(x: 0.0, y: 0.0, width: self.image.imageWidth, height: self.image.imageHeight).contains(pixelCoordinate) {
            return nil
        }
        return CGPoint(x: trunc(pixelCoordinate.x), y: trunc(pixelCoordinate.y))
    }
    
    private func colorCount(filter: ColorHistogramFilter, colorInfoCount: Int) -> Int
    {
        if let unwrappedK = filter.colorCount?.intValue {
            if unwrappedK <= 0 || unwrappedK > colorInfoCount {
                return colorInfoCount
            } else {
                return unwrappedK
            }
        }
        
        return colorInfoCount
    }
    
    private func binCount(filter: ColorHistogramFilter) -> Int {
        switch (filter.precisionLevel) {
        case .Absolute:
            return 1
        case .High:
            return 16
        case .Mid:
            return 32
        case .Low:
            return 64
        }
    }
    
}

/**
 Private extension on UIImage for computing dimensional metadata at
 the pixel and byte-levels, as well as for rescaling.
 */
private extension UIImage
{
    var imageWidth:CGFloat {
        if let cgImage = self.cgImage {
            return CGFloat(cgImage.width)
        }
        
        return 0
    }
    
    var imageHeight:CGFloat {
        if let cgImage = self.cgImage {
            return CGFloat(cgImage.height)
        }
        
        return 0
    }
    
    var originalPixelCount:Int {
        return Int(imageWidth * imageHeight)
    }
    
    var rescaledImageWidth:CGFloat {
        return boundingRectForImageAnalysis.width;
    }
    
    var rescaledImageHeight:CGFloat {
        return boundingRectForImageAnalysis.height;
    }
    
    var boundingRectForImageAnalysis:CGRect {
        
        if originalPixelCount > (pixelBoundary * pixelBoundary) {
            let floatWidth = imageWidth
            let floatHeight = imageHeight
            let floatBoundary = CGFloat(pixelBoundary)
            let scaleFactor = (floatWidth > floatBoundary) ? (floatBoundary / floatWidth) : (floatBoundary / floatHeight)
            let transformedWidth = trunc(floatWidth * scaleFactor)
            let transformedHeight = trunc(floatHeight * scaleFactor)
            return CGRect(x: 0.0, y: 0.0, width: transformedWidth, height: transformedHeight)
        } else {
            return CGRect(x: 0.0, y: 0.0, width: imageWidth, height: imageHeight)
        }
    }
    
    var rescaledPixelCount:Int {
        return Int(rescaledImageWidth * rescaledImageHeight)
    }
    
    var totalPixelsInBytes:Int {
        return rescaledPixelCount * dataBytesPerPixel
    }
    
    var bytesPerRow:Int {
        return dataBytesPerPixel * Int(rescaledImageWidth)
    }
    
    func byteLocationForPixel(pixelCoordinate:CGPoint) -> Int {
        let pointX = trunc(pixelCoordinate.x);
        let pointY = trunc(pixelCoordinate.y);
        return ((Int(rescaledImageWidth) * Int(pointY)) + Int(pointX)) * dataBytesPerPixel
    }
    
}

