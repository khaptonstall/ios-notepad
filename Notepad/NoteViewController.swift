//
//  NoteViewController.swift
//  Notepad
//
//  Created by Kyle Haptonstall on 1/18/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NoteViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    
    // MARK: - Class Variables
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteText: UITextView!
    
    
    var currentTitle: String?
    var currentText: String?
    var cellIndex:Int?
    
    
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "onSave")
        self.navigationItem.rightBarButtonItem = saveButton
        
        noteTitle.delegate = self
        noteText.delegate = self
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: noteTitle.frame.size.height - width, width:  noteTitle.frame.size.width, height: noteTitle.frame.size.height)
        border.borderWidth = width
        noteTitle.layer.addSublayer(border)
        noteTitle.layer.masksToBounds = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.noteTitle.text = currentTitle != nil ? currentTitle! : nil
        self.noteText.text = currentText != nil ? currentText! : nil
        
    }
    
    
    // MARK: - Class Methods
    
    
    /**
        Called when the Save button is pressed. Determines whether the note is a new or existing note and 
        calls the appropriate method to save the note
    
    */
    func onSave(){
        if noteTitle.text != nil && noteTitle.text != "" &&
            noteText.text != nil && noteText.text != ""{
                let title = noteTitle.text!
                let text = noteText.text!
                
                 cellIndex == nil ? saveNewNote(withTitle: title, andBody: text) : saveExistingNote(withTitle: title, andBody: text)
        }
        else{
            let alertView = UIAlertController(title: "Please enter title and note", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    
    /**
        Updates and save the existing note in Core Data.
     
     */
    func saveExistingNote(withTitle title:String, andBody text:String){
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Notes")
        do{
            let results = try context.executeFetchRequest(fetchRequest)
            if results.count - 1 >= cellIndex{
                let currentNote = results[cellIndex!]
                currentNote.setValue(title, forKey: "title")
                currentNote.setValue(text, forKey: "text")
                
                do{
                    try context.save()
                    let navigationController = self.navigationController
                    navigationController?.popViewControllerAnimated(true)
                    
                }catch{
                    print("Unable to save")
                }
            }
        }
        catch{
            print("Unable to fetch results")
        }
    }
    
    
    /**
        Creates and saves a new note object in Core Data.
     
     */
    func saveNewNote(withTitle title:String, andBody text:String){
        let context:NSManagedObjectContext = appDel.managedObjectContext
        
        let noteToSave = NSEntityDescription.insertNewObjectForEntityForName("Notes", inManagedObjectContext: context) as NSManagedObject
        noteToSave.setValue(title, forKey: "title")
        noteToSave.setValue(text, forKey: "text")
        noteToSave.setValue(NSDate(), forKey: "date")
        do{
            try context.save()
            let navigationController = self.navigationController
            navigationController?.popViewControllerAnimated(true)
        }
        catch{
            print("Unable to save note")
        }

    }
    
    // MARK: - UITextField Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}