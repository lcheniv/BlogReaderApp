//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Lawrence Chen on 2/18/16.
//  Copyright © 2016 Lawrence Chen. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Takes the app delegate and manages object context
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        
        let url = NSURL(string: "https://www.googleapis.com/blogger/v3/blogs/10861780/posts?key=AIzaSyBUcN7KAM-OMmkkeNRYMSTuGO-2lzxvDmQ")!
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            
            if error != nil {
                
                print(error)
                
            } else {
                
                
                // This unwraps data if it exists
                if let data = data {
                
                // Generate NSString with data
                // Also data is an optional so did a quick if let
                // print(NSString(data: data, encoding: NSUTF8StringEncoding))
                    
                    do {
                        
                        // Formats the data we retrieve
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        
                        // Making sure there are results available
                        if jsonResult.count > 0{
                            
                            // Getting items array - using if let because we don't know if it exist or it might get changed
                            // Casted to NSArray - filled with all the data from the Google Blog
                            if let items = jsonResult["items"] as? NSArray {
                                        
                                        let request = NSFetchRequest(entityName: "BlogItems")
                                        
                                        request.returnsObjectsAsFaults = false
                                        
                                        do {
                                            
                                            // Getting all items from blog items and then deleting them
                                            let results = try context.executeFetchRequest(request)
                                            
                                            if results.count > 0 {
                                                
                                                for result in results {
                                                    
                                                    // Deleting objects
                                                    context.deleteObject(result as! NSManagedObject)
                                                    
                                                    do {
                                                        
                                                        try context.save()
                                                        
                                                    } catch {}
                                                    
                                                }
                                                
                                            }
                                            
                                        } catch {
                                            
                                            // Left as empty
                                            
                                        }
                                        
                                        // Gets items in items
                                        for item in items {
                                            
                                            // Prints out all of the data from the items array
                                            // However we want to extract the content and title
                                            if let title = item["title"] as? String{
                                        
                                                if let content = item["content"] as? String {
                                        
                                                    // Creating a new post 
                                                    let newPost: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("BlogItems", inManagedObjectContext: context)
                                                    
                                                    // Set values for new post
                                                    newPost.setValue(title, forKey: "title")
                                                    newPost.setValue(content, forKey: "content")
                                                    
                                                    // This only prints the title and it's contents
                                                    // Also it contains some html, but that gets processed out by webview
                                                    // Now that we got these two data pieces we want to save it to our core data
//                                                    print(title)
//                                                    print(content)
                                                                                    }
                                    }
                                }
                                //print(items)
                                
                            }
                            
                        }
                        
                        //print(jsonResult)
                        
                    } catch {
                        
                        print("Error in NSJOSNSerialization")
                        
                    }
                }
            }
            
        }
        
        task.resume()
        
    
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    
    // Getting count of the number of items in the core data entity blog items
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.text = object.valueForKey("title")!.description
    }

    // MARK: - Fetched results controller
    // Just a handy way of interacting with core data

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        // Creating our entity - setting fetch request entity to that one
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("BlogItems", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate. Sorts by title
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    // UPDATES CONTROLLER WHEN CONTENT IS UPDATED - THATS WHY IMMEDIATE UPDATE EFFECT HAPPENS WHEN CONTENT IS DOWNLOADED
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    // Just tells the controller to end the updates when the content has been changed and everything has been updated
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

