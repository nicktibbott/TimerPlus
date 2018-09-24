//
//  TimersTableViewController.swift
//  Infini Timer
//
//  Created by Nick T on 8/31/18.
//  Copyright © 2018 Nick T. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

class TimersTableViewController: UITableViewController {
    
    @IBOutlet weak var noTimersLabel: UILabel!
    var numberOfTimers: CGFloat!
    var timers: [TimerObj] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTimerData()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {
            didAllow, error in
            
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTimerData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Timers")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    let timerValues = TimerObj()
                    if let hours = result.value(forKey: "hours") as? Int{
                        print(hours)
                        timerValues.hoursRemaining = CGFloat(hours)
                        timerValues.hoursOriginal = CGFloat(hours)
                    }
                    if let minutes = result.value(forKey: "minutes") as? Int{
                        print(minutes)
                        timerValues.minutesRemaining = CGFloat(minutes)
                        timerValues.minutesOriginal = CGFloat(minutes)
                    }
                    if let seconds = result.value(forKey: "seconds") as? Int{
                        print(seconds)
                        timerValues.secondsRemaining = CGFloat(seconds)
                        timerValues.secondsOriginal = CGFloat(seconds)
                    }
                    if let name = result.value(forKey: "name") as? String{
                        print(name)
                        timerValues.name = name
                    }
                    timerValues.startImmediately = false
                    timers.append(timerValues)
                }
            }
        }
        catch {
            
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return timers.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        noTimersLabel.isHidden = true

        let cell = tableView.dequeueReusableCell(withIdentifier: "timer", for: indexPath) as! TimerTableCell
        cell.timerValues = timers[indexPath.row]
        cell.adjustLabels()
        if !cell.timer.isValid{
            if cell.timerValues.startImmediately {
                cell.resume(cell.pausePlayButton)
            }
            else{
                //cell.pause(cell.pausePlayButton)
                
            }
        }
        
        return cell



         //Configure the cell...

        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Delete Timer", message: "Are you sure you would like to delete this timer?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                // Delete the row from the data source
                let cell = tableView.cellForRow(at: indexPath) as! TimerTableCell
                cell.timer.invalidate()
                cell.resume(cell.pausePlayButton)
                cell.timer.invalidate()
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [cell.timerValues.name])
                
                self.timers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if self.timers.count <= 0 {
                    self.noTimersLabel.isHidden = false
                }
                
                //Delete the timer from Core Data
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Timers")
                request.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(request)
                    
                    if results.count > 0 {
                        context.delete(results[indexPath.row] as! NSManagedObject)
                        try context.save()
                    }
                    
                }
                catch {}
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            

        }   
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
