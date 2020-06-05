//
//  BookmarkViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class BookmarkTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellSubtitle: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
}

class BookmarkViewController: UIViewController, RefreshTransitionListener {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    var bookmarks: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //change font for bar btn item
        editBtn.title = NSLocalizedString("Edit", comment: "")
        editBtn.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "ProximaNova-Bold", size: 14)!
        ], for: .normal)
        editBtn.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "ProximaNova-Bold", size: 14)!
        ], for: .selected)
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //hide separator line
        self.tableView.separatorColor = .clear;
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()

        //reload table
        tableView.reloadData()
        
        //customise navigation bar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "textColor")!]
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProximaNova-Light", size: 38)!]
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProximaNova-Bold", size: 14)!]
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.backgroundColor = UIColor(named: "bkColor")
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //retrieve bookmarks coredata
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
        
        super.viewDidAppear(animated)
        
//        //implement the refresh listener
        RefreshTransitionMediator.instance.setListener(listener: self)
        
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
    
    
//MARK: - Edit Bookmarks
    
    @IBAction func editBookmarks(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            self.editBtn.title = NSLocalizedString("Done", comment: "")
        } else {
            self.editBtn.title = NSLocalizedString("Edit", comment: "")
        }
    }
    
//MARK: - Delegate: Refresh News after Topic & Sources
    
    //required delegate func
    func popoverDismissed() {
//        self.navigationController?.dismiss(animated: true, completion: nil)
        self.viewWillAppear(true)
        print("dismissed")
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
            self.tableView.setEmptyMessage("Sem artigos")
        } else {
            self.tableView.restore()
        }
        return bookmarks.count
    }
    
    //create our cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookmarkTableViewCell
        
        let bookmark = bookmarks[indexPath.row]
        cell.cellTitle?.text = bookmark.value(forKeyPath: "headlineMarked") as? String
        
        //convert epoch with dateformatter
        let unixTimestamp = bookmark.value(forKeyPath: "epochMarked")
        let date = Date(timeIntervalSince1970: unixTimestamp as! TimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.init(identifier: Locale.preferredLanguages[1])
        dateFormatter.setLocalizedDateFormatFromTemplate("ddMMMM")
        let strDate = dateFormatter.string(from: date)
        
        cell.cellSubtitle?.text = strDate

        //set row img
        let image = UIImage(named: "placeholder.pdf")
        cell.cellImage?.kf.indicatorType = .activity
        cell.cellImage.layer.cornerRadius = 5.0

        let lang = bookmark.value(forKeyPath: "langMarked") as? String
        if lang == "Arabic" {
            cell.cellTitle?.textAlignment = NSTextAlignment.right
            cell.cellSubtitle?.textAlignment = NSTextAlignment.right
            let imgURL = (bookmark.value(forKeyPath: "imgMarked") as! String).addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
            let resource = ImageResource(downloadURL: (URL(string: imgURL! ) ??  URL(string:"https://wukela.app/assets/empty@3x.pdf"))!, cacheKey: imgURL)
            cell.cellImage?.kf.setImage(
                with: resource,
                placeholder: image,
                options: [.scaleFactor(UIScreen.main.scale),
                          .transition(.fade(0.5)),
                          .cacheOriginalImage
                ]
            )
        } else {
            cell.cellTitle?.textAlignment = NSTextAlignment.left
            cell.cellSubtitle?.textAlignment = NSTextAlignment.left
            let resource = ImageResource(downloadURL: URL(string: (bookmark.value(forKeyPath: "imgMarked") as? String)! )!, cacheKey: bookmark.value(forKeyPath: "imgMarked") as? String)
            cell.cellImage?.kf.setImage(
                with: resource,
                placeholder: image,
                options: [.scaleFactor(UIScreen.main.scale),
                          .transition(.fade(0.5)),
                          .cacheOriginalImage
                ]
            )
        }

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


