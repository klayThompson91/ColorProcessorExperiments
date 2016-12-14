//
//  BrandingPerformanceTests.swift
//  ColorExtractor
//
//  Created by Abhay Curam on 10/16/16.
//  Copyright © 2016 Abhay Curam. All rights reserved.
//

import XCTest
@testable import ColorExtractor

class BrandingPerformanceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testBestCasePerformance_mostFrequentColors() {
        // This is an example of a performance test case.
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: "YahooLogo", ofType: "png")
        let testImage = UIImage(contentsOfFile: imagePath!)
        let filter = ColorHistogramFilter.filterForSmallColorDistributions(colorCount: 20, ordering: .orderedDescending)
        let colorProcessor = ColorProcessor(image: testImage!)
        var histogram: [CountedColor] = [CountedColor]()
        self.measure {
            histogram = colorProcessor.extractColorHistogram(filter: filter)
        }
        
        print(histogram.count)
    }
    
    /*func testBestCasePerformance_dominantColor() {
     let bundle = Bundle(for: type(of: self))
     let imagePath = bundle.path(forResource: "YahooLogo", ofType: "png")
     let testImage = UIImage(contentsOfFile: imagePath!)
     let filter = ImageColorFilter.defaultImageFilter()
     let colorProcessor = ImageColorAnalyzer(imageToProcess: testImage!, filterToApply: filter)
     self.measure {
     _ = colorProcessor.getDominantColor()
     }
     }*/
    
    func testAverageCasePerformance_mostFrequentColors() {
        // This is an example of a performance test case.
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: "NetflixLogo", ofType: "jpg")
        let testImage = UIImage(contentsOfFile: imagePath!)
        let filter = ColorHistogramFilter.filterForSmallColorDistributions(colorCount: 20, ordering: .orderedDescending)
        let colorProcessor = ColorProcessor(image: testImage!)
        var histogram: [CountedColor] = [CountedColor]()
        self.measure {
            histogram = colorProcessor.extractColorHistogram(filter: filter)
        }
        
        print(histogram.count)
    }
    
    /*func testAverageCasePerformance_dominantColor() {
     let bundle = Bundle(for: type(of: self))
     let imagePath = bundle.path(forResource: "NetflixLogo", ofType: "jpg")
     let testImage = UIImage(contentsOfFile: imagePath!)
     let filter = ImageColorFilter.defaultImageFilter()
     let colorProcessor = ImageColorAnalyzer(imageToProcess: testImage!, filterToApply: filter)
     self.measure {
     _ = colorProcessor.getDominantColor()
     }
     }*/
}
