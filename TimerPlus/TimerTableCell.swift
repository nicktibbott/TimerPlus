//
//  TimerTableCell.swift
//  Infini Timer
//
//  Created by Nick T on 8/31/18.
//  Copyright © 2018 Nick T. All rights reserved.
//

import UIKit
import AudioToolbox
import UserNotifications

class TimerTableCell: UITableViewCell {

    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    var timerValues: TimerObj!
    var timer = Timer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(enteringBackground), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTimerFinished(){
        timerValues.hoursRemaining = 0
        timerValues.minutesRemaining = 0
        timerValues.secondsRemaining = 0
        adjustLabels()
        pausePlayButton.setTitle("↺", for: .normal)
        pausePlayButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .black)
        pausePlayButton.backgroundColor = UIColor.lightGray
        timer.invalidate()
    }
    
    @objc func enteringBackground(){
        timer.invalidate()
        UserDefaults.standard.set(Date(), forKey: nameLabel.text!)
    }
    
    @objc func willEnterForeground(){
        if let savedDate = UserDefaults.standard.object(forKey: nameLabel.text!) as? Date{
            if pausePlayButton.title(for: .normal) == "| |" {
                
                //fix time
                var secondsAway = -savedDate.timeIntervalSince(Date())
                while secondsAway > 60 {
                    while secondsAway > 3600 {
                        if timerValues.hoursRemaining > 0 {
                            timerValues.hoursRemaining = timerValues.hoursRemaining - 1
                            secondsAway -= 3600
                        }
                        else {
                            //timer has finished in the background
                            setTimerFinished()
                            return
                        }
                    }
                    
                    if timerValues.minutesRemaining > 0 {
                        timerValues.minutesRemaining = timerValues.minutesRemaining - 1
                        secondsAway -= 60
                    }
                    else {
                        if timerValues.hoursRemaining > 0 {
                            timerValues.hoursRemaining = timerValues.hoursRemaining - 1
                            timerValues.minutesRemaining = timerValues.minutesRemaining + 59
                            secondsAway -= 60
                        }
                        else{
                            //timer has finished in the background
                            setTimerFinished()
                            return
                        }
                    }
                }
                if timerValues.secondsRemaining > CGFloat(secondsAway) {
                    timerValues.secondsRemaining = timerValues.secondsRemaining - CGFloat(secondsAway)
                }
                else {
                    if timerValues.minutesRemaining > 0 {
                        timerValues.minutesRemaining = timerValues.minutesRemaining - 1
                        timerValues.secondsRemaining = 59 - (CGFloat(secondsAway) - timerValues.secondsRemaining)
                    }
                    else {
                        if timerValues.hoursRemaining > 0 {
                            timerValues.hoursRemaining = timerValues.hoursRemaining - 1
                            timerValues.minutesRemaining = timerValues.minutesRemaining + 59
                            timerValues.secondsRemaining = 59 - (CGFloat(secondsAway) - timerValues.secondsRemaining)
                        }
                        else {
                            //timer has finished in the background
                            setTimerFinished()
                            return
                        }
                    }
                }

                timerValues.secondsRemaining = round(timerValues.secondsRemaining)
                resume(pausePlayButton)
            }
        }
    }
    
    @objc func adjustTime(){
        //check if finished
        if timerValues.hoursRemaining <= 0 && timerValues.minutesRemaining <= 0 && timerValues.secondsRemaining <= 1 {
            
            setTimerFinished()
//            timer.invalidate()
//            timerValues.startImmediately = false
//            pausePlayButton.setTitle("↺", for: .normal)
//            pausePlayButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .black)
//            pausePlayButton.backgroundColor = UIColor.lightGray
            
            //alert
            AudioServicesPlaySystemSoundWithCompletion(1304, {})
        }
        else {
            //seconds adjust
            if timerValues.secondsRemaining > 0 {
                timerValues.secondsRemaining = timerValues.secondsRemaining - 1
            }
            else {
                timerValues.secondsRemaining = 59
                
                if timerValues.minutesRemaining > 0 {
                    timerValues.minutesRemaining = timerValues.minutesRemaining - 1
                }
                else {
                    timerValues.minutesRemaining = 59
                    timerValues.hoursRemaining = timerValues.hoursRemaining - 1
                }
            }
            
            adjustLabels()
        }
    }
    
    func adjustLabels(){
        if timerValues.hoursRemaining < 10 {
            hoursLabel.text = "0\(Int(timerValues.hoursRemaining!))"
        }
        else {
            hoursLabel.text = "\(Int(timerValues.hoursRemaining!))"
        }
        
        if timerValues.minutesRemaining < 10 {
            minutesLabel.text = "0\(Int(timerValues.minutesRemaining!))"
        }
        else {
            minutesLabel.text = "\(Int(timerValues.minutesRemaining!))"
        }
        
        if timerValues.secondsRemaining < 10 {
            secondsLabel.text = "0\(Int(timerValues.secondsRemaining!))"
        }
        else {
            secondsLabel.text = "\(Int(timerValues.secondsRemaining!))"
        }
        
        nameLabel.text = timerValues.name
    }

    @IBAction func changeTimerState(_ sender: UIButton) {
        if sender.title(for: .normal) == "| |" {
            pause(sender)
        }
        else if sender.title(for: .normal) == "▶"{
            resume(sender)
        }
        else if sender.title(for: .normal) == "↺"{
            reset(sender)
        }
    }
    
    func pause(_ sender: UIButton) {
        timer.invalidate()
        timerValues.startImmediately = false
        
        sender.setTitle("▶", for: .normal)
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .black)
        sender.backgroundColor = UIColor(displayP3Red: 0x61/255, green: 0xcf/255, blue: 0x67/255, alpha: 1)
        UIView.animate(withDuration: 0.2, animations: {
            sender.frame = CGRect(x: sender.frame.minX, y: sender.frame.minY, width: 52, height: sender.frame.height)
        }) { (complete) in
            self.resetButton.isHidden = false
        }
        
        //remove notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timerValues.name])
    }
    
    func resume(_ sender: UIButton) {
        adjustLabels()

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(adjustTime), userInfo: nil, repeats: true)
        
        sender.setTitle("| |", for: .normal)
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .black)
        sender.backgroundColor = UIColor(displayP3Red: 0xe7/255, green: 0x56/255, blue: 0x57/255, alpha: 1)
        self.resetButton.isHidden = true
        UIView.animate(withDuration: 0.2, animations: {
            sender.frame = CGRect(x: sender.frame.minX, y: sender.frame.minY, width: 90, height: sender.frame.height)
        })
        
        //add notification
        let content = UNMutableNotificationContent()
        content.title = timerValues.name
        content.body = "Timer done."
        content.sound = UNNotificationSound.default()
        
        let notificationDelaySeconds = Double(timerValues.secondsRemaining + (timerValues.minutesRemaining*60) + (timerValues.hoursRemaining*3600))
        
        if notificationDelaySeconds > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(timerValues.secondsRemaining + (timerValues.minutesRemaining*60) + (timerValues.hoursRemaining*3600)), repeats: false)
            let request = UNNotificationRequest(identifier: timerValues.name, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        resetButton.isHidden = true
        AudioServicesDisposeSystemSoundID(1304)
        timerValues.hoursRemaining = timerValues.hoursOriginal
        timerValues.minutesRemaining = timerValues.minutesOriginal
        timerValues.secondsRemaining = timerValues.secondsOriginal
        adjustLabels()
        pausePlayButton.setTitle("▶", for: .normal)
        pausePlayButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .black)
        pausePlayButton.backgroundColor = UIColor(displayP3Red: 0x61/255, green: 0xcf/255, blue: 0x67/255, alpha: 1)
        UIView.animate(withDuration: 0.2, animations: {
            self.pausePlayButton.frame = CGRect(x: self.pausePlayButton.frame.minX, y: self.pausePlayButton.frame.minY, width: 90, height: self.pausePlayButton.frame.height)
        })
    }
    
}
