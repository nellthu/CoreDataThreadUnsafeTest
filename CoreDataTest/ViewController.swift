//
//  ViewController.swift
//  CoreDataTest
//
//  Created by Pavel Minárik on 25/11/15.
//  Copyright © 2015 Pavel Minárik. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // True here means everything is context-thread-safe, false means context is accessed from different threads at the same time
    let safe = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let delegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        let context = delegate.managedObjectContext
        
        // Delete old entries
        let fetchRequest = NSFetchRequest(entityName: "Entity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.executeRequest(deleteRequest)
        try? context.save()

        // Fill the database
        for i in 1...100 {
            let entity = NSEntityDescription.insertNewObjectForEntityForName("Entity", inManagedObjectContext: context) as! Entity
            entity.name = "hovno"
            entity.value = NSNumber(integer: i)
        }
        
        // Prepare time to fire the requests at the same time
        let timeInFuture = NSDate().dateByAddingTimeInterval(5)
        
        func dispatchTimeIntervalToDate(date: NSDate) -> dispatch_time_t {
            return dispatch_time(DISPATCH_TIME_NOW, Int64(timeInFuture.timeIntervalSinceNow * Double(NSEC_PER_SEC)))
        }
        
        // Spawn the queues with the requests
        for i in 1...20 {
            let privateQueue = dispatch_queue_create("queue\(i)", DISPATCH_QUEUE_SERIAL)
            
            dispatch_after(dispatchTimeIntervalToDate(timeInFuture), privateQueue) {

                let fetchRequest = NSFetchRequest(entityName: "Entity")
                fetchRequest.predicate = NSPredicate(format: "name = %@", argumentArray: ["hovno"])

                if self.safe {
                    context.performBlock {
                        let results = try? context.executeFetchRequest(fetchRequest) as! [Entity]
                        
                        results?.forEach { $0.id = "Last accessed from queue \(i)" }
                        
                        try? context.save()
                        
                        print("Queue \(i) finished")
                    }
                } else {
                    let results = try? context.executeFetchRequest(fetchRequest) as! [Entity]
                    
                    results?.forEach { $0.id = "Last accessed from queue \(i)" }
                    
                    try? context.save()
                    
                    print("Queue \(i) finished")
                }
            }
        }
    }

}

