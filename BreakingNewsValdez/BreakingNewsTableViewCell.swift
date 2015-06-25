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
    @IBOutlet weak var isFavorite: UISwitch!;
    

    weak var story: Story?;
    
    func switchChanged(switchState: UISwitch) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        if (switchState.on) {
            story!.isFavorite = true
        } else {
            story!.isFavorite = false
        }
        let err : NSErrorPointer = NSErrorPointer()
        managedContext.save(err);
    }
    
}
