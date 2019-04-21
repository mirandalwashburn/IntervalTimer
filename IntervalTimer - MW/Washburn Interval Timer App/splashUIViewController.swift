//
//  splashUIViewController.swift
//  Washburn Interval Timer App
//
//  Created by Miranda Washburn on 11/16/18.
//  Copyright © 2018 Miranda Washburn. All rights reserved.
//

import UIKit
import CoreData



class splashUIViewController: UIViewController {
    /********** VARIABLES ************/
    /*********************************/
    var myTimer:Timer! = nil
    var remaining = 3
    var circle = ["circle_1", "circle_1", "circle_2", "circle_3"]
    
    @IBOutlet weak var circleImage: UIImageView!
    
    /************* LOAD **************/
    /*********************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        //TIMER FOR SPLASH SCREEN
        remaining = 3
        startTimer()
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /********** FUNCTIONS ************/
    /*********************************/
    //START TIMER
    func startTimer() {
    self.circleImage.image = UIImage(named: self.circle[3])
        remaining = 3
        myTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { myTimer in
            if self.remaining > 1 {
                self.remaining -= 1
                self.circleImage.image = UIImage(named: self.circle[self.remaining])

            } else {
                myTimer.invalidate()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainController = storyboard.instantiateViewController(withIdentifier: "mainScreen")
             self.present(mainController, animated:true, completion: nil)
         //    self.circleImage.image = UIImage(named: "void") //remove flash 1 to 3

                
            }
        }
    }

}
