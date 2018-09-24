//
//  AddTimerVC.swift
//  Infini Timer
//
//  Created by Nick T on 8/30/18.
//  Copyright © 2018 Nick T. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

class AddTimerVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var timerNameTextField: UITextField!
    @IBOutlet weak var timerPickerView: UIPickerView!
    var hoursSelected: CGFloat!
    var minutesSelected: CGFloat!
    var secondsSelected: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerNameTextField.tintColor = UIColor.darkGray
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nameEditingDidBegin(_ sender: Any) {
        //timerNameTextField.attributedPlaceholder = NSAttributedString(string: "Set Timer Name", attributes: [.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func start(_ sender: Any) {
        if hoursSelected == 0 && minutesSelected == 0 && secondsSelected == 0{
            timeSelectionError()
        }
        if hoursSelected == 0 && minutesSelected == nil && secondsSelected == nil{
            timeSelectionError()
        }
        if hoursSelected == 0 && minutesSelected == 0 && secondsSelected == nil{
            timeSelectionError()
        }
        if hoursSelected == nil && minutesSelected == nil && secondsSelected == 0{
            timeSelectionError()
        }
        if hoursSelected == nil && minutesSelected == 0 && secondsSelected == 0{
            timeSelectionError()
        }
        if hoursSelected == nil && minutesSelected == 0 && secondsSelected == nil{
            timeSelectionError()
        }
        
        if hoursSelected != nil || minutesSelected != nil || secondsSelected != nil{
            
            if timerNameTextField.text != "" {
                createTimer()
                createNotification()
                if UserDefaults.standard.value(forKey: "saveTimers") as! Bool {
                    saveTimerData()
                }
                navigationController?.popViewController(animated: true)
            }
            else {
                nameSelectionError()
            }
        }
        else {
            timeSelectionError()
        }
    }
    
    func createNotification(){
        //----- create and start notification ----//
        let content = UNMutableNotificationContent()
        content.title = timerNameTextField.text!
        content.body = "Timer done."
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(secondsSelected + (minutesSelected*60) + (hoursSelected*3600)), repeats: false)
        let request = UNNotificationRequest(identifier: timerNameTextField.text!, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func createTimer(){
        //timer is valid. start timer
        let previousVC = navigationController?.viewControllers[(navigationController?.viewControllers.count)! - 2] as! TimersTableViewController
        if hoursSelected == nil {
            hoursSelected = 0
        }
        if minutesSelected == nil {
            minutesSelected = 0
        }
        if secondsSelected == nil {
            secondsSelected = 0
        }
        let timer = TimerObj(hours: hoursSelected, minutes: minutesSelected, seconds: secondsSelected, name: timerNameTextField.text!)
        previousVC.timers.append(timer)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func timeSelectionError(){
        errorLabel.isHidden = false
        
        UIView.animate(withDuration: 0.05, animations: {
            self.errorLabel.frame = CGRect(x: self.errorLabel.frame.minX + 10, y: self.errorLabel.frame.minY, width: self.errorLabel.frame.width, height: self.errorLabel.frame.height)
        }) { (complete) in
            UIView.animate(withDuration: 0.05, animations: {
                self.errorLabel.frame = CGRect(x: self.errorLabel.frame.minX - 20, y: self.errorLabel.frame.minY, width: self.errorLabel.frame.width, height: self.errorLabel.frame.height)
            }) { (complete) in
                UIView.animate(withDuration: 0.05, animations: {
                    self.errorLabel.frame = CGRect(x: self.errorLabel.frame.minX + 10, y: self.errorLabel.frame.minY, width: self.errorLabel.frame.width, height: self.errorLabel.frame.height)
                })
            }
        }
    }
    
    func nameSelectionError(){
        // Shake name textfield
        
        UIView.animate(withDuration: 0.05, animations: {
            self.timerNameTextField.frame = CGRect(x: 10, y: self.timerNameTextField.frame.minY, width: self.timerNameTextField.frame.width, height: self.timerNameTextField.frame.height)
        }) { (complete) in
            UIView.animate(withDuration: 0.05, animations: {
                self.timerNameTextField.frame = CGRect(x: -10, y: self.timerNameTextField.frame.minY, width: self.timerNameTextField.frame.width, height: self.timerNameTextField.frame.height)
                
            }) { (complete) in
                UIView.animate(withDuration: 0.05, animations: {
                    self.timerNameTextField.frame = CGRect(x: 0, y: self.timerNameTextField.frame.minY, width: self.timerNameTextField.frame.width, height: self.timerNameTextField.frame.height)
                }, completion: { (complete) in
                    self.timerNameTextField.becomeFirstResponder()
                })
            }
        }
        
        //F2AAAA
        timerNameTextField.attributedPlaceholder = NSAttributedString(string: "Set Timer Name", attributes: [.foregroundColor: UIColor(displayP3Red: 0xf2/255, green: 0xaa/255, blue: 0xaa/255, alpha: 1)])
    }
    
    func saveTimerData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTimer = NSEntityDescription.insertNewObject(forEntityName: "Timers", into: context)
        newTimer.setValue(hoursSelected, forKey: "hours")
        newTimer.setValue(minutesSelected, forKey: "minutes")
        newTimer.setValue(secondsSelected, forKey: "seconds")
        newTimer.setValue(timerNameTextField.text, forKey: "name")
        
        do {
            try context.save()
        }
        catch {
            //error saving
        }
    }
    
    /* Picker View Delegate and Data Source*/
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        }
        if component == 1 {
            return 60
        }
        else {
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 25))
        timeLabel.text = "\(row)"
        timeLabel.textAlignment = .right
        timeLabel.font = UIFont.systemFont(ofSize: 22)
        view?.addSubview(timeLabel)
        return timeLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hoursSelected = CGFloat(row)
        }
        if component == 1 {
            minutesSelected = CGFloat(row)
        }
        if component == 2 {
            secondsSelected = CGFloat(row)
        }
        errorLabel.isHidden = true
    }
    
     //MARK: - Navigation

     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         //Get the new view controller using segue.destinationViewController.
         //Pass the selected object to the new view controller.
        
     
    }

}

