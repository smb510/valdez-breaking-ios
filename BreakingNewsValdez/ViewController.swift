//
//  ViewController.swift
//  BreakingNewsValdez
//
//  Created by Scott Biddle on 4/13/15.
//  Copyright (c) 2015 Sbunticot Enterprises. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var stories = [Story]()
    var displayAllStories : Bool = true
    
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
        loadStories(displayAllStories)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func switchViewMode(segmentedControl: UISegmentedControl) {
        if (displayAllStories) {
            //now show only favorites
            segmentedControl.selectedSegmentIndex = 1
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
        displayAllStories = !displayAllStories
        loadStories(displayAllStories)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: BreakingNewsTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! BreakingNewsTableViewCell
        cell.switchChanged()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 1
        } else if (section == 1) {
            return stories.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let headerCell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Header") as! UITableViewCell
            let switcherView : UISegmentedControl = headerCell.viewWithTag(445) as! UISegmentedControl
            switcherView.addTarget(self, action: "switchViewMode:", forControlEvents: UIControlEvents.ValueChanged)
            return headerCell
        } else {
            let cell: BreakingNewsTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! BreakingNewsTableViewCell
            let incidentBody: String = stories[indexPath.row].eventBody
            let incidentType: String = stories[indexPath.row].eventType
            let incidentDate: NSNumber = stories[indexPath.row].importDate
            var isFavorite: Bool? = stories[indexPath.row].isFavorite.boolValue
            cell.story = stories[indexPath.row]
            cell.isFavorite.hidden = !(isFavorite!)
            cell.incidentType.text = incidentType
            cell.incidentBody.text = incidentBody
            let date : NSDate = NSDate(timeIntervalSince1970: incidentDate.doubleValue / 1000)
            cell.incidentDate.text = NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
            return cell
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
        let url : String = "http://datelinevaldez.com/stories?last=" + queryId.stringValue
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
                    let story = Story(entity: entity!,
                        insertIntoManagedObjectContext:managedContext)
                    story.setValuesForKeysWithDictionary(dict as! NSDictionary as [NSObject : AnyObject])
                    var error: NSError?
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.loadStories(self.displayAllStories)
                self.refreshControl?.endRefreshing()
                });
        });
        task.resume()
    }
    
    func loadStories(displayAllStories: Bool) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        //2
        let fetchRequest = NSFetchRequest(entityName:"Story")
        
        let sortDescriptor : NSSortDescriptor = NSSortDescriptor(key: "importDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if (!displayAllStories) {
            fetchRequest.predicate = NSPredicate(format: "isFavorite == %i", 1)
        }
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [Story]?
        
        if fetchedResults != nil {
            stories = fetchedResults!
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        tableView?.reloadData()
    }
    
    func showOptions() {
        self.performSegueWithIdentifier("showFilters", sender: self)
    }
    


}

