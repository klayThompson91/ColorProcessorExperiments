//
//  ColorExtractorViewController.swift
//  ColorExtractor
//
//  Created by Abhay Curam on 9/30/16.
//  Copyright © 2016 Abhay Curam. All rights reserved.
//

import UIKit

class ColorExtractorViewController: UIViewController {

    @IBOutlet weak var inputImage: UIImageView!
    
    @IBAction func rightCycleButton(_ sender: AnyObject) {
        if imageIndex < (images.count - 1) {
            imageIndex = imageIndex + 1
            inputImage.image = images[imageIndex]
            processImageAndUpdateViews(imageToProcess: images[imageIndex])
        }
    }
    
    @IBAction func leftCycleButton(_ sender: AnyObject) {
        if imageIndex > 0 {
            imageIndex = imageIndex - 1
            inputImage.image = images[imageIndex]
            processImageAndUpdateViews(imageToProcess: images[imageIndex])
        }
    }
    
    @IBOutlet weak var dominantColorView: UIView!
    @IBOutlet weak var firstColorView: UIView!
    @IBOutlet weak var secondColorView: UIView!
    @IBOutlet weak var thirdColorView: UIView!
    @IBOutlet weak var fourthColorView: UIView!
    @IBOutlet weak var fifthColorView: UIView!
    @IBOutlet weak var sixthColorView: UIView!
    @IBOutlet weak var seventhColorView: UIView!
    @IBOutlet weak var eigthColorView: UIView!
    @IBOutlet weak var dominantColorRunTimeLabel: UILabel!
    @IBOutlet weak var topKColorsRunTimeLabel: UILabel!
    
    private var images: [UIImage?] = [UIImage(named: "BlueElephant"), UIImage(named: "UniversityOfMichiganLogo"), UIImage(named: "YahooLogo"), UIImage(named: "PinkBlackPhones"), UIImage(named: "ParkPhoto"), UIImage(named: "CatKing"), UIImage(named: "PayPalLogo"), UIImage(named: "NasaVisibleEarth")]
    private var imageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        inputImage.image = images[imageIndex]
        processImageAndUpdateViews(imageToProcess: images[imageIndex])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func processImageAndUpdateViews(imageToProcess: UIImage?)
    {
        if let image = imageToProcess {
            
            let filter = ColorHistogramFilter(precisionLevel: .Absolute, pixelInterpolationQuality: CGInterpolationQuality.high, colorCount: 8, ordering: .orderedDescending)
            let colorProcessor = ColorProcessor(image: image)
            
            var startTime = CACurrentMediaTime()
            var endTime = CACurrentMediaTime()
            dominantColorRunTimeLabel.text = String(format: "%.6f", endTime - startTime)
            
            startTime = CACurrentMediaTime()
            let topColors = colorProcessor.extractColorHistogram(filter: filter)
            endTime = CACurrentMediaTime()
            topKColorsRunTimeLabel.text = String(format: "%.6f", endTime - startTime)
            
            dominantColorView.backgroundColor = UIColor.white
            
            if 0 < topColors.count {
                firstColorView.backgroundColor = topColors[0].color
                print("Color: \(topColors[0].color) || Count: \(topColors[0].count)")
            }
            
            if 1 < topColors.count {
                secondColorView.backgroundColor = topColors[1].color
                print("Color: \(topColors[1].color) || Count: \(topColors[1].count)")
            }
            
            if 2 < topColors.count {
                thirdColorView.backgroundColor = topColors[2].color
                print("Color: \(topColors[2].color) || Count: \(topColors[2].count)")
            }
            
            if 3 < topColors.count {
                fourthColorView.backgroundColor = topColors[3].color
                print("Color: \(topColors[3].color) || Count: \(topColors[3].count)")
            }
            
            if 4 < topColors.count {
                fifthColorView.backgroundColor = topColors[4].color
                print("Color: \(topColors[4].color) || Count: \(topColors[4].count)")
            }
            
            if 5 < topColors.count {
                sixthColorView.backgroundColor = topColors[5].color
                print("Color: \(topColors[5].color) || Count: \(topColors[5].count)")
            }
            
            if 6 < topColors.count {
                seventhColorView.backgroundColor = topColors[6].color;
                print("Color: \(topColors[6].color) || Count: \(topColors[6].count)")
            }
            
            if 7 < topColors.count {
                eigthColorView.backgroundColor = topColors[7].color;
                print("Color: \(topColors[7].color) || Count: \(topColors[7].count)")
            }
        }
    }

}

