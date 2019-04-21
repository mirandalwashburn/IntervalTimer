//
//  SecondaryViewController.swift
//  Washburn Interval Timer App
//
//  Created by Miranda Washburn on 11/11/18.
//  Copyright © 2018 Miranda Washburn. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

/***PROTOCOLS***/
protocol SecondViewControllerDelegate: class {
    func textChanged(text:String?)
    func activeTime(text:String?)
    func restTime(text:String?)
    func numIntervals(text:String?)
}

/********** SECONDARY CLASS ************/
class SecondaryViewController: UIViewController {
 weak var delegate: SecondViewControllerDelegate?
    
    /****OUTLETS****/
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var intervalsLabel: UILabel!
    
    @IBOutlet weak var startLabel: UIButton!
    @IBOutlet weak var pauseLabel: UIButton!
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    //Top Navigation
    @IBOutlet weak var resetLabel: UIButton!
    @IBOutlet weak var backArrow: UIButton!


    //Audio
    var audioPlayer: AVAudioPlayer?
    // var notificationSound:String = ""
    var beep:String = "beep"
    
    //Feedback Label
    @IBOutlet weak var feedbackLabel: UILabel!
    
    
    /****VARIABLES****/
    //Reading Data From Previous Screen
     var totalTimeValue: String? = ""
     var activeSeconds:String? = nil
     var restSeconds:String? = nil
     var numOfIntervals:String? = nil
    
    //New Variables
    var secondsActive = 0
    var secondsRest = 0
    var totalTimer = 0

    
    var timer = Timer()
    var isTimerRunning = false
    var resumePushed = false
    var resetPushed = false
    var activeTime = false
    
   
    //UI COLORS
    let softBlue = UIColor(red:0.27, green:0.27, blue:0.36, alpha:1.0)
    let softGrey = UIColor(red:0.44, green:0.77, blue:1.00, alpha:1.0)
    let softGreen = UIColor(red:0.38, green:0.70, blue:0.51, alpha:1.0)
    let blueColor = UIColor(red:0.57, green:0.73, blue:0.80, alpha:1.0)
    let textColor = UIColor(red:0.85, green:0.85, blue:0.86, alpha:1.0)
    let finalBgColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)

    
    
    /***********************************/
    /********** OVERRIDE FUNC **********/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         timeLabel.text = totalTimeValue
         activeLabel.text = activeSeconds
         restLabel.text = restSeconds
        intervalsLabel.text = numOfIntervals
        runTimer()
        updateTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /************ BUTTONS **************/
    /***********************************/
    //Start Button
    @IBAction func startButton(_ sender: UIButton) {

       if self.resumePushed == false  {
            timer.invalidate()
            self.resumePushed = true
            self.startLabel.setTitle("Start", for: .normal)
        } else {
            runTimer()
            self.resumePushed = false
            self.startLabel.setTitle("Pause", for: .normal)
        }
        //Disable the start button
        if totalTimer == 0 {
            startLabel.isEnabled = false
        }
        
    }
    
    /***********************************/
    //Reset Button
    @IBAction func resetButton(_ sender: UIButton) {
       if resetPushed == false {
        timer.invalidate()
        
        //Countdown Label Reset
        let active = Int(activeSeconds!)
        let rest = Int(restSeconds!)
        let totalNumOfIntervals = Int(numOfIntervals!)
        let time = "\((rest! + active!) * totalNumOfIntervals!)"
   
        secondsRest = rest! + 1
        totalTimer = Int(time)!
        
        //Time Strings
        timeLabel.text = timeString(time: TimeInterval(totalTimer))
        
        //Change the screen back to the restTime styles
        restTimeScreen()
        resetRestTimer()
        
        isTimerRunning = false
        self.resumePushed = true
        self.startLabel.setTitle("Start", for: .normal)
    
        } else {
       // startButton()
        isTimerRunning = true
        runTimer()
        
        }
    }
    
    @IBAction func backArrowButton(_ sender: UIButton) {
        //Invalidate Timer so when you go back, the audio doesn't keep beeping
        timer.invalidate()
    }
    /************ FUNCTIONS ************/
    /***********************************/
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        //   pauseLabel.isEnabled = true
    }
    @objc func updateTimer() {
        timeCycle()
        totalTime()
    }
    /***********************************/
    //Time String
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 360
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
  
    
    
    /***********************************/
    // Create the time cycle
    func timeCycle() {
        if timeString(time: TimeInterval(secondsActive)) < "00:00:01" {
            restTimer()
        }
        if timeString(time: TimeInterval(secondsRest)) < "00:00:01" {
            activeTimer()
        }

    }
    
    /***********************************/
    //Active Timer
    func activeTimer() {
        let active = Int(activeSeconds!)
        if secondsActive < 1  {
            secondsActive = active!
            activityLabel.text = "Go!"
            backgroundView.backgroundColor = softBlue
            startLabel.backgroundColor = softGreen
            startLabel.setTitleColor(.white, for: .normal)
            activityLabel.textColor = softGreen
            playAudio(audio: beep)
        } else {
            secondsActive -= 1
        }
        countdownLabel.text = timeString(time: TimeInterval(secondsActive))
        //Add this piece in again so the active timer never reaches 00:00:00
        if timeString(time: TimeInterval(secondsActive)) < "00:00:01" {
            restTimer()
        }
  
      
    }
    
    /***********************************/
    //Rest Timer
    func restTimer() {
        let rest = Int(restSeconds!)
        if secondsRest < 1 {
            secondsRest = rest!
            restTimeScreen()
            playAudio(audio: beep)
        } else {
            secondsRest -= 1
        }
        countdownLabel.text = timeString(time: TimeInterval(secondsRest))
    }
    
    /***********************************/
    //Store rest Time Styles in a function so you can call it again when the reset button is pushed.
    func restTimeScreen() {
        /*Activity Label */
        activityLabel.text = "Rest"
        activityLabel.textColor = UIColor.lightGray
        
        /* Start Label */
        startLabel.backgroundColor = softGreen
        startLabel.setTitleColor(.white, for: .normal)
        
        /* ViewBackground Color*/
        backgroundView.backgroundColor = UIColor.darkGray
        
        /*BACK ARROW */
        backArrow.setTitleColor(blueColor, for: .normal)
        
        /*Time Remaining */
        timeLabel.textColor = textColor
        remainingTimeLabel.textColor = textColor
    }
    
    /***********************************/
    func resetRestTimer() {
        let rest = Int(restSeconds!)
        if secondsRest < 1 {
            secondsRest = rest!
            restTimeScreen()
        } else {
            secondsRest -= 1
        }
        countdownLabel.text = timeString(time: TimeInterval(secondsRest))
    }
    
    /***********************************/
    //Calculate the total time -- make it a running clock, so user can see how much of their workout is left.
    func totalTime() {
        let rest = Int(restSeconds!)
        let active:Int = Int(activeSeconds!)!
        let totalIntervals:Int = Int(numOfIntervals!)!
        let calculateTime = Int((rest! + active) * totalIntervals)
        
        timeLabel.text = "\(calculateTime)"
        
        //Make the Total Timer Label countdown
        let time = Int(calculateTime)
        if totalTimer < 1 {
            totalTimer = time
        }
        else {
            totalTimer  -= 1
        }

        /*TIMES UP*/
        if totalTimer == 0 {
            timer.invalidate()
            activityLabel.text = "Time's Up!"
            countdownLabel.text = "00:00:00"
            
            //Styles
            backgroundView.backgroundColor = finalBgColor
            activityLabel.textColor = softBlue
            timeLabel.textColor = softBlue
            remainingTimeLabel.textColor = softBlue
            
            //Play two beeps when workout is done
            playAudioDouble(audio: beep)
            
            //Change the styles of the Start Button
            startLabel.isHidden = true
            startLabel.backgroundColor = UIColor.clear
            startLabel.setTitleColor(UIColor.clear, for: .normal)
            
            //Change the color of the back button & Countdown label
            backArrow.setTitleColor(softGreen, for: .normal)
            countdownLabel.textColor = softBlue
           
        }
        timeLabel.text = timeString(time: TimeInterval(totalTimer))
    }
    
    /***********************************/
    func startButton() {
        if self.resumePushed == false  {
            timer.invalidate()
            self.resumePushed = true
            self.startLabel.setTitle("Start", for: .normal)
        } else {
            runTimer()
            self.resumePushed = false
            self.startLabel.setTitle("Pause", for: .normal)
        }

    }

    
    /************ AUDIO ****************/
    /***********************************/
    func playAudio(audio:String) {
        guard let url=Bundle.main.path(forResource: audio, ofType:"mp3") else {return}
        feedbackLabel.text = "File Found. " + url
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath:url))
            audioPlayer!.play()
        } catch let error {
            feedbackLabel.text = "Error: \(error.localizedDescription)"
        }
    }
    /***********************************/
    //Make the beep go off three times when workout is done
    func playAudioDouble(audio:String) {
        guard let url=Bundle.main.path(forResource: audio, ofType:"mp3") else {return}
        feedbackLabel.text = "File Found. " + url
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath:url))
            audioPlayer?.numberOfLoops = 3
            audioPlayer!.play()
        } catch let error {
            feedbackLabel.text = "Error: \(error.localizedDescription)"
        }

    }

}
