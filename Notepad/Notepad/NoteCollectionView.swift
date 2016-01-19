//
//  NoteCollectionView.swift
//  Notepad
//
//  Created by Kyle Haptonstall on 1/18/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class NoteCell: UICollectionViewCell{
    @IBOutlet weak var noteTitle: UILabel!
    var noteText:String?
}



class NoteCollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    // MARK: - Class Variables
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var movingCell:NSIndexPath?
    var notesArray = [AnyObject]()
    var currentCellIndex:Int?
    var logo = UIImageView(frame: CGRectMake(0, 0, 30, 30))
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - UIViewController Controller Methods
    override func viewDidLoad() {
        setUpNavBar()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        currentCellIndex = nil
        loadNotes(){ _ in
            dispatch_async(dispatch_get_main_queue()){
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Class Methods
    
    /**
        Called when view first loads to set up and display app logo and set up Edit button.
    
    */
    func setUpNavBar(){
        
        logo.image = UIImage(named: "Icon")
        logo.frame.origin.x = (self.view.frame.size.width - logo.frame.size.width) / 2
        logo.frame.origin.y = 25
        self.navigationController?.view.addSubview(logo)
        self.navigationController?.view.bringSubviewToFront(logo)
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "onEdit")
    }
    
    
    /** 
        Called when Edit is pressed. Allows the user to begin deleting notes with a single tap.
     
     */
    func onEdit(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "onDone")
        self.logo.hidden = true
        self.navigationItem.title = "Tap to Delete"
    }
    
    
    /**
        Called when Done is pressed. Switches user out of the delete mode.
     */
    func onDone(){
         self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "onEdit")
        
        self.navigationItem.title = nil
        self.logo.hidden = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "onEdit")
    }
  
    
    /**
        Fetches data from Core Data and saves the results to the notesArray.
     
        - parameter completion: A completion handler that returns when the fetch has finished.

     */
    func loadNotes(completion: (() -> Void)){
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Notes")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.executeFetchRequest(request)
            notesArray = results
            completion()
        }
        catch _{
            print("No data")
        }
        
    }
    
    
    // MARK: - Collection View Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if navigationItem.leftBarButtonItem?.style == .Done{
            let managedContext = appDel.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Notes")
            fetchRequest.returnsObjectsAsFaults = false
            do{
                var results = try managedContext.executeFetchRequest(fetchRequest)
                managedContext.deleteObject(results[indexPath.row] as! NSManagedObject)
                notesArray.removeAtIndex(indexPath.row)
                
                do{
                    try managedContext.save()
                    collectionView.reloadData()
                }catch{
                    print("Unable to save")
                }
                
            }
            catch{
                print("Unable to fetch")
            }
        }
        else{
            currentCellIndex = indexPath.item
            self.performSegueWithIdentifier("ShowExistingNote", sender: collectionView.cellForItemAtIndexPath(indexPath))
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: NoteCell = collectionView.dequeueReusableCellWithReuseIdentifier("NoteCell", forIndexPath: indexPath) as! NoteCell
        
        if let title:String = notesArray[indexPath.row].valueForKey("title") as? String,
               text:String = notesArray[indexPath.row].valueForKey("text") as? String{
                
            cell.noteTitle.text = title
            cell.noteText = text
        }
        
        return cell
    }
    
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowExistingNote"{
            let cell = sender as! NoteCell
            let destination = segue.destinationViewController as! NoteViewController
            destination.currentTitle = cell.noteTitle.text
            destination.currentText = cell.noteText
            destination.cellIndex = currentCellIndex
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.navigationItem.leftBarButtonItem?.style == .Done{
            return false
        }
        
        if identifier == "ShowExistingNote" && currentCellIndex == nil{
            return false
        }
        
        return true
    }
    
    
}