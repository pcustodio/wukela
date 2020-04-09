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
            bookmarks = try managedContext.fetch(fetchRequest).reversed()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //check for internet availability
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "Connection Error", message: "Please check if your internet connection is active.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler:{(action:UIAlertAction!) in
                print("Action")
                if Reachability.isConnectedToNetwork(){
                    self.viewWillAppear(animated)
                } else{
                    self.viewDidAppear(animated)
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    
    //MARK: - Segue to WebViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "getNews" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as? WebViewController
                let bookmark = bookmarks[indexPath.row]
                destination?.url = bookmark.value(forKeyPath: "urlMarked") as! String
                destination?.headline = bookmark.value(forKeyPath: "headlineMarked") as! String
                destination?.source = bookmark.value(forKeyPath: "sourceMarked") as! String
                destination?.epoch = bookmark.value(forKeyPath: "epochMarked") as! Double
            }
        }
    }
}
    
//MARK: - TableView

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate {

    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bookmarks.count == 0 {
            //display empty bookmarks msg
            self.tableView.setEmptyMessage("Sem notas")
        } else {
            self.tableView.restore()
        }
        return bookmarks.count
    }
    
    //create our cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let bookmark = bookmarks[indexPath.row]
        cell.textLabel?.text = bookmark.value(forKeyPath: "headlineMarked") as? String
        
        //convert epoch with dateformatter
        let unixTimestamp = bookmark.value(forKeyPath: "epochMarked")
        let date = Date(timeIntervalSince1970: unixTimestamp as! TimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.init(identifier: Locale.preferredLanguages[1])
        dateFormatter.setLocalizedDateFormatFromTemplate("ddMMMM")
        let strDate = dateFormatter.string(from: date)
        
        cell.detailTextLabel?.text = strDate
//        cell.detailTextLabel?.text = "\(strDate), \(bookmark.value(forKeyPath: "sourceMarked") as! String)"

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

//MARK: - Empty message

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor(named: "lineColor")
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "ProximaNova-Light", size: 30)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
