//
//  ViewController.swift
//  Washburn Interval Timer App
//
//  Created by Miranda Washburn on 9/28/18.
//  Copyright © 2018 Miranda Washburn. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController, SecondViewControllerDelegate {
 /************** OUTLETS *************/
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var intervalsRemainingLabel: UILabel!
    @IBOutlet weak var activTimeTextField: UITextField!
    @IBOutlet weak var restTimeTextField: UITextField!
    @IBOutlet weak var numberOfIntervalsTextField: UITextField!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    //Button Labels
    @IBOutlet weak var pauseLabel: UIButton!
    @IBOutlet weak var startLabel: UIButton!
    @IBOutlet weak var resetLabel: UIButton!
    
    //Stepper Labels
    @IBOutlet weak var activeTimeStepper: UIStepper!
    @IBOutlet weak var restTimeStepper: UIStepper!
    @IBOutlet weak var numOfIntervalsStepper: UIStepper!
    
    //Testing Labels
    @IBOutlet weak var feedbackLabel: UILabel!
    

   /*********** VARIABLES *************/
    //User Defined
    var secondsActive = 0
    var secondsRest = 0
    var totalTimer = 0
    var intervalTest = 0
    
    //Timer
    var timer = Timer()
    var isTimerRunning = false
    var resumePushed = false
    
    //Core Data
    var appDel:AppDelegate = AppDelegate()
    var context:NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    
   /************** LOAD *************/
    override func viewDidLoad() {
        timer.invalidate()
        super.viewDidLoad()
        
        //Save Settings
        appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.persistentContainer.viewContext
       
        //Fetch saved data
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            feedbackLabel.text = "Results fetched."

            for data in result as! [NSManagedObject] {
                let activeSaveTime:String? = data.value(forKey:"setActiveTime") as? String
                let restSaveTime:String? = data.value(forKey:"setRestTime") as? String
                let intervalSave:String? = data.value(forKey:"setInterval") as? String
               let totalTimeSave:String? = data.value(forKey:"setTotalTime") as? String
                
                if activeSaveTime != nil {
                    activTimeTextField.text = (data.value(forKey: "setActiveTime") as! String)
                }
                if restSaveTime != nil {
                    restTimeTextField.text = (data.value(forKey:"setRestTime") as! String)
                }
                if intervalSave != nil {
                    numberOfIntervalsTextField.text = (data.value(forKey:"setInterval") as! String)
                }
                if totalTimeSave != nil {
                    totalTimeLabel.text = (data.value(forKey:"setTotalTime") as! String)
                }
            }
        } catch {
            feedbackLabel.text = ("Failed to fetch data.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   /************ ACTIONS *************/
   /**********************************/
   //Splash Screen Button
    @IBAction func showSplashButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    //Transfer Stepper Values to next window
    override func prepare(for seque: UIStoryboardSegue,sender: Any?) {
        if let secondViewController = seque.destination as? SecondaryViewController {
            secondViewController.totalTimeValue = totalTimeLabel.text
            secondViewController.activeSeconds = activTimeTextField.text
            secondViewController.restSeconds = restTimeTextField.text
            secondViewController.numOfIntervals = numberOfIntervalsTextField.text
            secondViewController.delegate = self
        }
    }
    func textChanged(text: String?) {
        totalTimeLabel.text = text
    }
     func activeTime(text:String?) {
        activTimeTextField.text = text
    }
    func restTime(text:String?) {
        restTimeTextField.text = text
    }
    func numIntervals(text:String?) {
        numberOfIntervalsTextField.text = text
    }


    //************** STEPPERS ***************
    //Since interface says seconds, don't use decimals
    @IBAction func activeTimeStepper(_ sender: UIStepper) {
        activTimeTextField.text = Int(sender.value).description
        updateTimeWhenValueChanged()
         saveSettings()
    }
    @IBAction func restTimeStepper(_ sender: UIStepper) {
        restTimeTextField.text = Int(sender.value).description
        updateTimeWhenValueChanged()
        saveSettings()
    }
    @IBAction func numOfIntervalsStepper(_ sender: UIStepper) {
        numberOfIntervalsTextField.text = Int(sender.value).description
        //Displays the correct number of intervals before the Start button is pressed (without the next lines of code, the first value will be one less than the total)
        let totalIntervals = Int(numOfIntervalsStepper.value)
        intervalsRemainingLabel.text = String("\(totalIntervals) / \(totalIntervals)")
        updateTimeWhenValueChanged()
         saveSettings()
        
    }
    
 
    /************ FUNCTIONS ***********/
    /**********************************/
    //RUN THE TIMER
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    @objc func updateTimer() {
         timeCycle()
         totalTime()
    }
    
   /**********************************/
    //CREATE THE TIME STRING
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 360
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }

    /**********************************/
    //CREATE THE TIME CYCLE
    func timeCycle() {
            if timeString(time: TimeInterval(secondsRest)) == "00:00:00" {
                activeTimer()
            }
            if timeString(time: TimeInterval(secondsActive)) == "00:00:00" {
                restTimer() 
               // remainingIntervals()
        }
    }
    
   /**********************************/
   //ACTIVE TIMER
    func activeTimer() {
        let active = Int(activTimeTextField.text!)
        if secondsActive < 1  {
            secondsActive = active!

        } else {
            secondsActive -= 1
        }
        countDownLabel.text = timeString(time: TimeInterval(secondsActive))
    }
    
    /**********************************/
    //REST TIMER
    func restTimer() {
        let rest = Int(restTimeTextField.text!)
        if secondsRest < 1 {
            secondsRest = rest!
            activityLabel.text = "Rest"
        } else {
            secondsRest -= 1
        }
        countDownLabel.text = timeString(time: TimeInterval(secondsRest))
    }
    
    /**********************************/
    //UPDATE TIME WHEN VALUE CHANGED
    func updateTimeWhenValueChanged() {
        let rest = Int(activeTimeStepper.value)
        let active = Int(restTimeStepper.value)
        let totalIntervals = Int(numOfIntervalsStepper.value)
        
        let totalT:Double = Double((rest + active) * totalIntervals)
        //Make the Total Timer Label countdown
        totalTimeLabel.text = timeString(time: TimeInterval(totalT))
    }
    
    /**********************************/
    //CALCULATE TOTAL TIME
    //Make it a running clock, so user can see how much of their workout is left.
    func totalTime() {
        let rest = Int(restTimeTextField.text!)
        let active = Int(activTimeTextField.text!)
        let totalIntervals = Int(numOfIntervalsStepper.value)
        totalTimeLabel.text = "\((rest! + active!) * totalIntervals)"
        let time = Int(totalTimeLabel.text!)
       
        if totalTimer < 1 {
            totalTimer = time! + 1
        } else {
            totalTimer  -= 1
        }
        /*TIMES UP*/
        if totalTimer == 0 {
            timer.invalidate()
            activityLabel.text = "Time's Up!"
            countDownLabel.text = "00:00:00"
        }
        totalTimeLabel.text = timeString(time: TimeInterval(totalTimer))
     


//Work on this after Final. (not working currently) SAVE FOR LATER
//NOTE ** I change the alpha of the Intervals Label and the 0/0 Label to zero so you can't see it.
        var remainingIntervals  = Int(numOfIntervalsStepper.value)
        let rest1 = Int(restTimeStepper.value)
        let active1 = Int(activeTimeStepper.value)
        let restActiveTime:Int = Int(rest1 + active1)
        let maxTime:Int = ((rest1 + active1) * totalIntervals)
        if totalTimer % restActiveTime == 0 {
            remainingIntervals -= 1
        }
        // Don't change the interval at the beginning
        if (totalTimer == maxTime) || (totalTimer == (maxTime + 1)) {
           remainingIntervals = totalIntervals
        }
        // Make sure the intervals are zero at the end
        if totalTimer < 1  {
            remainingIntervals = 0
        }
        intervalsRemainingLabel.text = String("\(remainingIntervals) / \(totalIntervals)") 
    }
    
    
    /**********************************/
    //SAVE SETTINGS
    func saveSettings() {
    let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context)
    let newActiveSeconds = NSManagedObject(entity: entity!, insertInto: context)
    let newRestSeconds = NSManagedObject(entity: entity!, insertInto: context)
    let newInterval = NSManagedObject(entity: entity!, insertInto: context)
    let newTotalTimer = NSManagedObject(entity: entity!, insertInto: context)
        
        
    //Stepper Values for saving
    let rest = Int(restTimeStepper.value)
    let active = Int(activeTimeStepper.value)
    let intervals = Int(numOfIntervalsStepper.value)
    let totalTime1 = ((rest + active) * intervals)
    let totalTimeString = timeString(time: TimeInterval(totalTime1))

    newActiveSeconds.setValue("\(active)", forKey: "setActiveTime")
    newRestSeconds.setValue("\(rest)", forKey: "setRestTime")
    newInterval.setValue("\(intervals)", forKey: "setInterval")
    newTotalTimer.setValue("\(totalTimeString)", forKey: "setTotalTime")
        
    do {
    try context.save()
    feedbackLabel.text = "Data saved"
    
    } catch {
    feedbackLabel.text = ("Data failed to save.")
    }
    }
    
    /**********************************/
    //REMOVE OLD RECORDS
    func removeOldRecords() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        do {
            let myResults =  try context.fetch(request)
            if myResults.count > 0 {
                feedbackLabel.text = "Results fetched \(myResults.count) records"
                for xyz in myResults as! [NSManagedObject] {
                    let myDataObject:NSManagedObject = xyz
                    context.delete(xyz)
                }
            }
        } catch {
            feedbackLabel.text = "Failed to delete records."
        }
    }
}


