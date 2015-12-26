//
//  ViewController.swift
//  TestPaintCode
//
//  Created by Mark Broski on 12/22/15.
//  Copyright © 2015 Mark Broski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var clockView: ClockView!
    
    override dynamic func viewDidAppear(animated: Bool) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.clockView.updateCirclePadding(0)
            
        }
    }


    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        self.clockView.setNeedsDisplay()
    }
    
    
}

