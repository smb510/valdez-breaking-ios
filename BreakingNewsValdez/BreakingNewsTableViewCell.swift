//
//  BreakingNewsTableViewCell.swift
//  BreakingNewsValdez
//
//  Created by Scott Biddle on 4/14/15.
//  Copyright (c) 2015 Sbunticot Enterprises. All rights reserved.
//

import Foundation
import UIKit

class BreakingNewsTableViewCell: UITableViewCell {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
    @IBOutlet weak var incidentType: UILabel!;
    @IBOutlet weak var incidentBody: UILabel!;
    @IBOutlet weak var incidentDate: UILabel!;
    @IBOutlet weak var isFavorite: UIImageView!;
    

    weak var story: Story?;
    
    func switchChanged() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        if (story!.isFavorite.boolValue) {
            isFavorite.hidden = true;
        } else {
            isFavorite.hidden = false;
        }
        story!.isFavorite = !(story!.isFavorite.boolValue)
        let err : NSErrorPointer = NSErrorPointer()
        managedContext.save(err);
    }
    
}
