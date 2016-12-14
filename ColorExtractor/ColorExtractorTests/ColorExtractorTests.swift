//
//  ColorExtractorTests.swift
//  ColorExtractorTests
//
//  Created by Abhay Curam on 9/30/16.
//  Copyright © 2016 Abhay Curam. All rights reserved.
//

import XCTest
@testable import ColorExtractor

class ColorExtractorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
  /*  func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testBestCasePerformance_mostFrequentColors() {
        // This is an example of a performance test case.
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: "YahooLogo", ofType: "png")
        let testImage = UIImage(contentsOfFile: imagePath!)
        let filter = ImageColorFilter.defaultImageFilter()
        let colorProcessor = ImageColorAnalyzer(imageToProcess: testImage!, filterToApply: filter)
        self.measure {
            _ = colorProcessor.getMostFrequentColors()
        }
    }
    
    func testBestCasePerformance_dominantColor() {
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: "YahooLogo", ofType: "png")
        let testImage = UIImage(contentsOfFile: imagePath!)
        let filter = ImageColorFilter.defaultImageFilter()
        let colorProcessor = ImageColorAnalyzer(imageToProcess: testImage!, filterToApply: filter)
        self.measure {
            _ = colorProcessor.getDominantColor()
        }
    }
    
    func testAverageCasePerformance_dominantColor_catKing() {
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: "CatKing", ofType: "png")
        let testImage = UIImage(contentsOfFile: imagePath!)
        let filter = ImageColorFilter.defaultImageFilter()
        let colorProcessor = ImageColorAnalyzer(imageToProcess: testImage!, filterToApply: filter)
        self.measure {
            _ = colorProcessor.getDominantColor()
        }
    }
    
    func testAverageCasePerformance_dominantColor_parkPhoto() {
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: "ParkPhoto", ofType: "png")
        let testImage = UIImage(contentsOfFile: imagePath!)
        let filter = ImageColorFilter.defaultImageFilter()
        let colorProcessor = ImageColorAnalyzer(imageToProcess: testImage!, filterToApply: filter)
        self.measure {
            _ = colorProcessor.getDominantColor()
        }
    }
    
    func testAverageCasePerformance_mostFrequentColors_catKing() {
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: "CatKing", ofType: "png")
        let testImage = UIImage(contentsOfFile: imagePath!)
        let filter = ImageColorFilter.defaultImageFilter()
        let colorProcessor = ImageColorAnalyzer(imageToProcess: testImage!, filterToApply: filter)
        self.measure {
            _ = colorProcessor.getMostFrequentColors()
        }
    }
    
    func testAverageCasePerformance_mostFrequentColors_parkPhoto() {
        let bundle = Bundle(for: type(of: self))
        let imagePath = bundle.path(forResource: "ParkPhoto", ofType: "png")
        let testImage = UIImage(contentsOfFile: imagePath!)
        let filter = ImageColorFilter.defaultImageFilter()
        let colorProcessor = ImageColorAnalyzer(imageToProcess: testImage!, filterToApply: filter)
        self.measure {
            _ = colorProcessor.getMostFrequentColors()
        }
    }
    */
}
