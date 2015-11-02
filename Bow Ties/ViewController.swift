//
//  ViewController.swift
//  Bow Ties
//
//  Created by Pietro Rea on 7/12/15.
//  Copyright © 2015 Razeware. All rights reserved.
//

import UIKit

import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    var managedContext: NSManagedObjectContext!
    var currentBowtie: Bowtie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.insertSampleData()
        
        let request = NSFetchRequest(entityName: "Bowtie")
        let firstTitle = segmentedControl.titleForSegmentAtIndex(0)
        request.predicate = NSPredicate(format: "searchKey == %@", firstTitle!)
        
        do {
            let results = try managedContext.executeFetchRequest(request) as! [Bowtie]
            self.currentBowtie = results.first
            self.populate(self.currentBowtie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func populate(bowtie: Bowtie) {
        self.imageView.image = UIImage(data: bowtie.photoData!)
        self.nameLabel.text = bowtie.name
        self.ratingLabel.text = "Rating: \(bowtie.rating!.doubleValue)/5"
        self.timesWornLabel.text = "# times worn: \(bowtie.timesWorn!.integerValue)"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        self.lastWornLabel.text = "Last worn: " + dateFormatter.stringFromDate(bowtie.lastWorn!)
        self.favoriteLabel.hidden = !bowtie.isFavorite!.boolValue
        
        self.view.tintColor = bowtie.tintColor as! UIColor
    }
    
    func insertSampleData() {
        let fetchRequest = NSFetchRequest(entityName: "Bowtie")
        fetchRequest.predicate = NSPredicate(format: "searchKey !=nil")
        
        let count = self.managedContext.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 { return }
        
        let path = NSBundle.mainBundle().pathForResource("SampleData", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict: AnyObject in dataArray {
            let entity = NSEntityDescription.entityForName("Bowtie", inManagedObjectContext: self.managedContext)
            let bowtie = Bowtie(entity: entity!, insertIntoManagedObjectContext: self.managedContext)
            let btDict = dict as! NSDictionary
            
            bowtie.name = btDict["name"] as? String
            bowtie.searchKey = btDict["searchKey"] as? String
            bowtie.rating = btDict["rating"] as? NSNumber
            let tintColorDict = btDict["tintColor"] as? NSDictionary
            bowtie.tintColor = colorFromDict(tintColorDict!)
            
            let imageName = btDict["imageName"] as? String
            let image = UIImage(named: imageName!)
            let photoData = UIImagePNGRepresentation(image!)
            bowtie.photoData = photoData
            
            bowtie.lastWorn = btDict["lastWorn"] as? NSDate
            bowtie.timesWorn = btDict["timesWorn"] as? NSNumber
            bowtie.isFavorite = btDict["isFavorite"] as? NSNumber
        }
    }
    
    func colorFromDict(dict: NSDictionary) -> UIColor {
        let red = dict["red"] as! NSNumber
        let green = dict["green"] as! NSNumber
        let blue = dict["blue"] as! NSNumber
        
        let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
        
        return color
    }
    
    @IBAction func segmentedControl(control: UISegmentedControl) {
        
    }
    
    @IBAction func wear(sender: AnyObject) {
        let times = currentBowtie.timesWorn!.integerValue
        self.currentBowtie.timesWorn = NSNumber(integer: times + 1)
        self.currentBowtie.lastWorn = NSDate()
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.localizedDescription)")
        }
        
        populate(currentBowtie)
    }
    
    @IBAction func rate(sender: AnyObject) {
        let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.updateRating(textField.text!)
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.keyboardType = .NumberPad
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateRating(numericString: String) {
        self.currentBowtie.rating = (numericString as NSString).doubleValue
        
        do {
            try managedContext.save()
            self.populate(self.currentBowtie)
        } catch let error as NSError {
            print("Could not save \(error), \(error.localizedDescription)")
        }
    }
}

