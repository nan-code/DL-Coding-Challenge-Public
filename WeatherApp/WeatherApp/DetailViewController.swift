//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Matthew Nanney on 7/15/16.
//  Copyright © 2016 Matthew Nanney. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var viewCurrentTemp: UIView!
    @IBOutlet weak var viewForecast: UIView!
    @IBOutlet weak var viewForecastType: UIView!

    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblFeelsLikeTemp: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    
    @IBOutlet weak var imgViewCondition: UIImageView!
    
    @IBOutlet weak var collectionViewForecast: UICollectionView!
    @IBOutlet weak var segControlForecastType: UISegmentedControl!
    


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
//            if let label = self.detailDescriptionLabel {
//                label.text = detail.description
//            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

