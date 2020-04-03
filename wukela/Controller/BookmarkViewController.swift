//
//  BookmarkViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class BookmarkViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var bookmarks: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //hide separator line
        //self.tableView.separatorColor = .clear;
        
        //set cell height
        self.tableView.rowHeight = 60;
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()

        //reload table
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
      
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
              return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bookmarks")
        do {
            bookmarks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
}
    
//MARK: - TableView

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate {

    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        if bookmarks.count == 0 {

            //display empty bookmarks msg

        } else {
            print(bookmarks.count)
        }
        return bookmarks.count
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let bookmark = bookmarks[indexPath.row]
        cell.textLabel?.text = bookmark.value(forKeyPath: "headlineMarked") as? String
        cell.detailTextLabel?.text = bookmark.value(forKeyPath: "sourceMarked") as? String

        return cell
        
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //will print cell that was tapped on
        //print(indexPath.row)

        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //swipe to delete rows in Coredata
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let bookmark = bookmarks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            guard let moc = bookmark.managedObjectContext else { return }
            moc.delete(bookmark)
            moc.processPendingChanges()
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
    }
}
