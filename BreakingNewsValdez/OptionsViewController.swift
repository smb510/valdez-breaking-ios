//
//  OptionsViewController.swift
//  BreakingNewsValdez
//
//  Created by Scott Biddle on 5/6/15.
//  Copyright (c) 2015 Sbunticot Enterprises. All rights reserved.
//

import UIKit
import CoreData

class OptionsViewController : UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var types = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        loadEventTypes()
    }
    
    func loadEventTypes() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        //2
        let fetchRequest = NSFetchRequest(entityName:"Story")
        fetchRequest.propertiesToFetch = ["eventType"]
        fetchRequest.returnsDistinctResults = true
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            types = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        tableView?.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("FilterCell") as? UITableViewCell
        var title: UILabel = cell?.viewWithTag(1234) as! UILabel
        let incidentType: String = (types[indexPath.row] as NSManagedObject).valueForKey("eventType") as! String
        title.text = incidentType
        return cell!
    }
    
    
}
