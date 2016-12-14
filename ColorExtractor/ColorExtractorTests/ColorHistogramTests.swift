//
//  ColorProcessorTests.swift
//  ColorProcessorTests
//
//  Created by Abhay Curam on 11/18/16.
//  Copyright © 2016 Workday. All rights reserved.
//

import XCTest
@testable import ColorExtractor

let imageType = "png"
let absolutePrecisionImage = "MultiColor_AbsolutePrecision"
let midPrecisionImage = "MultiColor_MidPrecision"
let highPrecisionImage = "MultiColor_HighPrecision"
let twoHundredSquareImage = "200x200_Image"
let threeHundredSquareImage = "300x300_Image"
let fourEightySquareImage = "480x480_Image"

let queryColorAtPixelErrorMessage = "ColorProcessor failed to return the correct color, colors not equal."
let queryColorAtInvalidPixelErrorMessage = "Attempted to query a color for an invalid pixel point, processor should have returned nil"
let colorHistogramColorExtractionErrorMessage = "ColorProcessor extractHistogram failed to extract some color values."
let colorHistogramUnnecessaryRescaleErrorMessage = "ColorProcessor rescaled an image when it shouldn't have."

class ColorProcessorTests: XCTestCase {
    
    var absoluteColors = [ CountedColor(color: UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1), colorCount: 30),
                           CountedColor(color: UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1), colorCount: 25),
                           CountedColor(color: UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1), colorCount: 20),
                           CountedColor(color: UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1), colorCount: 10),
                           CountedColor(color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1), colorCount: 5),
                           CountedColor(color: UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1), colorCount: 4),
                           CountedColor(color: UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1), colorCount: 4),
                           CountedColor(color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), colorCount: 2)  ]
    
    var highColors = [ CountedColor(color: UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1), colorCount: 30),
                       CountedColor(color: UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1), colorCount: 25),
                       CountedColor(color: UIColor(red: 0/255, green: 56/255, blue: 232/255, alpha: 1), colorCount: 31),
                       CountedColor(color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), colorCount: 5),
                       CountedColor(color: UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1), colorCount: 4),
                       CountedColor(color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1), colorCount: 5)  ]
    
    var midColors = [  CountedColor(color: UIColor(red: 48/255, green: 255/255, blue: 0/255, alpha: 1), colorCount: 31),
                       CountedColor(color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1), colorCount: 32),
                       CountedColor(color: UIColor(red: 112/255, green: 0/255, blue: 144/255, alpha: 1), colorCount: 9),
                       CountedColor(color: UIColor(red: 144/255, green: 0/255, blue: 176/255, alpha: 1), colorCount: 15),
                       CountedColor(color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), colorCount: 13)  ]
    
    // MARK: ColorProcessor - extractColorHistogram() Tests
    
    func testExtractColorHistogram_withAbsolutePrecision()
    {
        let testImage = fetchImage(imageNamed: absolutePrecisionImage)
        let descendingFilter = ColorHistogramFilter.filterForSmallColorDistributions(colorCount: 0, ordering: .orderedDescending)
        let ascendingFilter = ColorHistogramFilter.filterForSmallColorDistributions(colorCount: nil, ordering: .orderedAscending)
        let colorProcessor = ColorProcessor(image: testImage)
        let descendingHistogram = colorProcessor.extractColorHistogram(filter: descendingFilter)
        let ascendingHistogram = colorProcessor.extractColorHistogram(filter: ascendingFilter)
        
        
        assertAndVerifyHistogram(histogram: descendingHistogram, testColors: absoluteColors, ordering: .orderedDescending, histogramCount: 8)
        assertAndVerifyHistogram(histogram: ascendingHistogram, testColors: absoluteColors, ordering: .orderedAscending, histogramCount: 8)
    }
    
    /// Integration test as well as Color Binning Test
    func testExtractColorHistogram_withHighPrecision()
    {
        let testImage = fetchImage(imageNamed: highPrecisionImage)
        let descendingFilter = ColorHistogramFilter.filterForMediumColorDistributions(colorCount: 0, ordering: .orderedDescending)
        let ascendingFilter = ColorHistogramFilter.filterForMediumColorDistributions(colorCount: nil, ordering: .orderedAscending)
        let colorProcessor = ColorProcessor(image: testImage)
        let descendingHistogram = colorProcessor.extractColorHistogram(filter: descendingFilter)
        let ascendingHistogram = colorProcessor.extractColorHistogram(filter: ascendingFilter)
        
        assertAndVerifyHistogram(histogram: descendingHistogram, testColors: highColors, ordering: .orderedDescending, histogramCount: 6)
        assertAndVerifyHistogram(histogram: ascendingHistogram, testColors: highColors, ordering: .orderedAscending, histogramCount: 6)
    }
    
    /// Integration test as well as Color Binning Test
    func testExtractColorHistogram_withMidPrecision()
    {
        let testImage = fetchImage(imageNamed: midPrecisionImage)
        let descendingFilter = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: 0, ordering: .orderedDescending)
        let ascendingFilter = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: nil, ordering: .orderedAscending)
        let colorProcessor = ColorProcessor(image: testImage)
        let descendingHistogram = colorProcessor.extractColorHistogram(filter: descendingFilter)
        let ascendingHistogram = colorProcessor.extractColorHistogram(filter: ascendingFilter)
        
        assertAndVerifyHistogram(histogram: descendingHistogram, testColors: midColors, ordering: .orderedDescending, histogramCount: 5)
        assertAndVerifyHistogram(histogram: ascendingHistogram, testColors: midColors, ordering: .orderedAscending, histogramCount: 5)
    }
    
    func testHistogramFilterCountLimits_properlyApplied()
    {
        let testImage = fetchImage(imageNamed: midPrecisionImage)
        let filterWithCountLessThanTotal = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: 4, ordering: .orderedSame)
        let filterWithCountEqualToTotal = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: 5, ordering: .orderedSame)
        let filterWithCountGreaterThanTotal = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: 6, ordering: .orderedSame)
        let colorProcessor = ColorProcessor(image: testImage)
        
        var histogram = colorProcessor.extractColorHistogram(filter: filterWithCountLessThanTotal)
        XCTAssertEqual(histogram.count, 4, "ColorProcessor extractHistogram failed to limit the number of colors returned.")
        histogram = colorProcessor.extractColorHistogram(filter: filterWithCountEqualToTotal)
        XCTAssertEqual(histogram.count, 5, colorHistogramColorExtractionErrorMessage)
        histogram = colorProcessor.extractColorHistogram(filter: filterWithCountGreaterThanTotal)
        XCTAssertNotEqual(histogram.count, 6, "The test failed because ColorProcessor extracted unexpected colors.")
        XCTAssertEqual(histogram.count, 5, colorHistogramColorExtractionErrorMessage)
    }
    
    func testHistogramBoundedByK()
    {
        let testImage = fetchImage(imageNamed: midPrecisionImage)
        let filterWithCountOfOneDescending = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: 1, ordering: .orderedDescending)
        let filterWithCountOfThreeDescending = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: 3, ordering: .orderedDescending)
        let filterWithCountOfOneAscending = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: 1, ordering: .orderedAscending)
        let filterWithCountOfThreeAscending = ColorHistogramFilter.filterForLargeColorDistributions(colorCount: 3, ordering: .orderedAscending)
        let colorProcessor = ColorProcessor(image: testImage)
        let topColorHistogram = colorProcessor.extractColorHistogram(filter: filterWithCountOfOneDescending)
        let topThreeColorsHistogram = colorProcessor.extractColorHistogram(filter: filterWithCountOfThreeDescending)
        let minColorHistogram = colorProcessor.extractColorHistogram(filter: filterWithCountOfOneAscending)
        let minThreeColorsHistogram = colorProcessor.extractColorHistogram(filter: filterWithCountOfThreeAscending)
        assertAndVerifyHistogram(histogram: topColorHistogram, testColors: midColors, ordering: .orderedDescending, histogramCount: 1)
        assertAndVerifyHistogram(histogram: topThreeColorsHistogram, testColors: midColors, ordering: .orderedDescending, histogramCount: 3)
        assertAndVerifyHistogram(histogram: minColorHistogram, testColors: midColors, ordering: .orderedAscending, histogramCount: 1)
        assertAndVerifyHistogram(histogram: minThreeColorsHistogram, testColors: midColors, ordering: .orderedAscending, histogramCount: 3)
        
    }
    
    func testHistogramImageRescaling()
    {
        let rescaleRect = CGRect(x: 0.0, y: 0.0, width: 300, height: 300)
        let originalRect = CGRect(x: 0.0, y: 0.0, width: 200, height: 200)
        var testImage = fetchImage(imageNamed: twoHundredSquareImage)
        let colorProcessor = ColorProcessor(image: testImage)
        XCTAssertEqual(colorProcessor.imageRect, originalRect, colorHistogramUnnecessaryRescaleErrorMessage)
        
        testImage = fetchImage(imageNamed: threeHundredSquareImage)
        colorProcessor.image = testImage
        XCTAssertEqual(colorProcessor.imageRect, rescaleRect, colorHistogramUnnecessaryRescaleErrorMessage)
        
        testImage = fetchImage(imageNamed: fourEightySquareImage)
        colorProcessor.image = testImage
        XCTAssertTrue((colorProcessor.imageRect.size.height * colorProcessor.imageRect.size.width <= 300 * 300), "ColorProcessor failed to rescale an image before processing.")
    }
    
    
    // MARK: ColorProcessor - queryColorAtPixel() Tests
    
    func testQueryColorAtPixel_readsCorrectColor()
    {
        let testImage = fetchImage(imageNamed: absolutePrecisionImage)
        let colorProcessor = ColorProcessor(image: testImage)
        var parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 1, y: 1))
        XCTAssertEqual(parsedColor, absoluteColors[0].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 3, y: 0))
        XCTAssertEqual(parsedColor, absoluteColors[1].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 1, y: 2))
        XCTAssertEqual(parsedColor, absoluteColors[2].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 9, y: 2))
        XCTAssertEqual(parsedColor, absoluteColors[3].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 9, y: 5))
        XCTAssertEqual(parsedColor, absoluteColors[5].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 8, y: 6))
        XCTAssertEqual(parsedColor, absoluteColors[6].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 6, y: 8))
        XCTAssertEqual(parsedColor, absoluteColors[4].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 9, y: 6))
        XCTAssertEqual(parsedColor, absoluteColors[7].color, queryColorAtPixelErrorMessage)
    }
    
    func testQueryColorsAtBoundaries()
    {
        let testImage = fetchImage(imageNamed: absolutePrecisionImage)
        let colorProcessor = ColorProcessor(image: testImage)
        var parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 0, y: 0))
        XCTAssertEqual(parsedColor, absoluteColors[0].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 0, y: 9))
        XCTAssertEqual(parsedColor, absoluteColors[0].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 9, y: 0))
        XCTAssertEqual(parsedColor, absoluteColors[0].color, queryColorAtPixelErrorMessage)
        parsedColor = colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 9, y: 9))
        XCTAssertEqual(parsedColor, absoluteColors[0].color, queryColorAtPixelErrorMessage)
    }
    
    func testQueryColorsOutsideBoundaries()
    {
        let testImage = fetchImage(imageNamed: absolutePrecisionImage)
        let colorProcessor = ColorProcessor(image: testImage)
        XCTAssertNil( (colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: -1, y: 0))), queryColorAtInvalidPixelErrorMessage )
        XCTAssertNil( (colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 0, y: -1))), queryColorAtInvalidPixelErrorMessage )
        XCTAssertNil( (colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: -1, y: 9))), queryColorAtInvalidPixelErrorMessage )
        XCTAssertNil( (colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 0, y: 10))), queryColorAtInvalidPixelErrorMessage )
        XCTAssertNil( (colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 9, y: -1))), queryColorAtInvalidPixelErrorMessage )
        XCTAssertNil( (colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 10, y: 0))), queryColorAtInvalidPixelErrorMessage )
        XCTAssertNil( (colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 9, y: 10))), queryColorAtInvalidPixelErrorMessage )
        XCTAssertNil( (colorProcessor.queryColorAtPixel(pixelCoordinate: CGPoint(x: 10, y: 9))), queryColorAtInvalidPixelErrorMessage )
    }
    
    
    // MARK: Private Test helper methods
    
    private func assertAndVerifyHistogram(histogram: [CountedColor], testColors: [CountedColor], ordering: ComparisonResult, histogramCount: Int)
    {
        XCTAssertEqual(histogram.count, histogramCount, colorHistogramColorExtractionErrorMessage)
        var sortedTestColors = [CountedColor]()
        switch ordering {
        case .orderedAscending:
            sortedTestColors = testColors.sorted {
                return $0.0.count < $0.1.count
            }
            break
        case .orderedDescending:
            sortedTestColors = testColors.sorted {
                return $0.0.count > $0.1.count
            }
            break
        case .orderedSame:
            break
        }
        
        if ordering != .orderedSame {
            for (index, color) in histogram.enumerated() {
                assertEqualCountedColors(colorOne: color, colorTwo: sortedTestColors[index])
            }
        } else {
            XCTAssertThrowsError("Histogram tests are broken, a sort of orderedSame should not be applicable to sorting tests.")
        }
    }
    
    private func assertEqualCountedColors(colorOne: CountedColor, colorTwo: CountedColor)
    {
        XCTAssertEqual(colorOne.color, colorTwo.color, "Color comparison Failure, color returned by histogram does not match input image. || ColorOne: \(colorOne.color), ColorTwo: \(colorTwo.color)")
        XCTAssertEqual(colorOne.count, colorTwo.count, "The count for a color returned by the histogram is incorrect. || Color: \(colorOne.color)")
    }
    
    private func fetchImage(imageNamed: String) -> UIImage
    {
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: imageNamed, ofType: imageType)
        return UIImage(contentsOfFile: imagePath!)!
    }
    
}
