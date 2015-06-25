//
//  ViewController.swift
//  BreakingNewsValdez
//
//  Created by Scott Biddle on 4/13/15.
//  Copyright (c) 2015 Sbunticot Enterprises. All rights reserved.
//

import UIKit
import CoreData
import Story

class ViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var stories = [Story]()
    
    @IBOutlet weak var filterButton : UIBarButtonItem?;

    override func viewDidLoad() {
        super.viewDidLoad()
        downloadJson()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 100.0;
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl = UIRefreshControl()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "downloadJson", forControlEvents: UIControlEvents.ValueChanged)
        loadStories()
//        filterButton!.target = self
//        filterButton!.action = "showOptions"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: BreakingNewsTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! BreakingNewsTableViewCell
        let incidentBody: String = stories[indexPath.row].eventBody
        let incidentType: String = stories[indexPath.row].eventType
        let incidentDate: NSNumber = stories[indexPath.row].importDate
        var isFavorite: Bool? = stories[indexPath.row].isFavorite
        cell.isFavorite.setOn(isFavorite!, animated: false)
        cell.isFavorite.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cell.incidentType.text = incidentType
        cell.incidentBody.text = incidentBody
        let date : NSDate = NSDate(timeIntervalSince1970: incidentDate.doubleValue / 1000)
        cell.incidentDate.text = NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        return cell
    }
    
    func switchChanged(switchState: UISwitch) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let storyToFavor = NSFetchRequest(entityName: "Story")
//        storyToFavor.predicate = NSPredicate(format: "id == %i", <#args: CVarArgType#>...)
        if (switchState.on) {
            
        }
        
    }
    
    
    
    
    func downloadJson() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let latestStory = NSFetchRequest(entityName: "Story")
        latestStory.fetchLimit = 1;
        let orderBy = NSSortDescriptor(key: "id", ascending: false)
        latestStory.sortDescriptors = [orderBy]
        var error: NSErrorPointer = nil;
        let result = managedContext.executeFetchRequest(latestStory, error: error) as? [NSManagedObject]
        var queryId: NSNumber = -1;
        if (result?.count > 0) {
            var first = result?[0]
            if ((first) != nil) {
                queryId = first!.valueForKey("id") as! Int
            }
        }
        let session: NSURLSession = NSURLSession.sharedSession();
        let url : String = "http://evening-oasis-4196.herokuapp.com/stories?last=" + queryId.stringValue
        var request: NSURLRequest = NSURLRequest(URL: NSURL(string: url)!);
        let task = session.dataTaskWithRequest(request, completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) in
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros,  error: nil) as! NSArray;
            var count = 0;
            for  dict in json {
                NSLog("%@", dict as! NSDictionary)
                let entity =  NSEntityDescription.entityForName("Story",
                    inManagedObjectContext:
                    managedContext)
                let req = NSFetchRequest(entityName: "Story")
                req.predicate = NSPredicate(format: "id == %i", dict["id"] as! NSInteger)
                var err: NSErrorPointer = nil;
                let res = managedContext.executeFetchRequest(req, error: err)
                if (res == nil || res!.count == 0) {
                    count += 1
                    let story = NSManagedObject(entity: entity!,
                        insertIntoManagedObjectContext:managedContext)
                    story.setValuesForKeysWithDictionary(dict as! NSDictionary as [NSObject : AnyObject])
                    var error: NSError?
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                }
            }
            self.loadStories()
            self.refreshControl?.endRefreshing()
        });
        task.resume()
    }
    
    func loadStories() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        //2
        let fetchRequest = NSFetchRequest(entityName:"Story")
        
        let sortDescriptor : NSSortDescriptor = NSSortDescriptor(key: "importDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [Story]?
        
        if let results = fetchedResults {
            stories = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        tableView?.reloadData()
    }
    
    func showOptions() {
        self.performSegueWithIdentifier("showFilters", sender: self)
    }
    


}

