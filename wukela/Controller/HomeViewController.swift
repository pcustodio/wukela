//
//  HomeViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RefreshTransitionListener {
    
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var refreshControl = UIRefreshControl()
    
    var headlineRead = ""
    var readHistory = [String]()
    
    private let notificationPublisher = NotificationPublisher()
    
    var newsSync = [[Any]]()
    
    
//MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload")
        
        newsRefresh()
        
        //implement the refresh listener
        RefreshTransitionMediator.instance.setListener(listener: self)
        
        //observe when app becomes active
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        //tabBar items
        if let tabItems = tabBarController?.tabBar.items {
            
            let tabItemOne = tabItems[0]
            let tabItemTwo = tabItems[1]
            let tabItemThree = tabItems[2]
            
            //vertically center sf-symbols
            tabItemOne.image = UIImage(systemName: "tray.full")!.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
            tabItemTwo.image = UIImage(systemName: "bookmark")!.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
            tabItemThree.image = UIImage(systemName: "antenna.radiowaves.left.and.right")!.withBaselineOffset(fromBottom: UIFont.systemFontSize / 2)
        }
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView.init(frame: .zero)
        
        //hide separator line
        self.tableView.separatorColor = .clear;
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //set cell height
        self.tableView.rowHeight = 80;
        
        //refresh control
        addRefreshControl()
        
        //segments
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        
        //customise navigation bar
        let navBarAppearance = UINavigationBarAppearance()
//        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowColor = .clear
//        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.backgroundColor = UIColor(named: "bkColor")
        navigationController?.navigationBar.standardAppearance = navBarAppearance
//        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
//        bottomView.setGradientBackground(colorOne: UIColor(white: 1, alpha: 0), colorTwo: UIColor(named: "eightBkColor")!, colorThree: UIColor(named: "nineBkColor")!, colorFour: UIColor(named: "bkColor")!)
            }
    
    
//MARK: - viewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        print("viewDidAppear")

        //check for checkmarks
        retrieveHistory()

    }
 
    
//MARK: - Local Notifications
    
    @IBAction func notifyBtn(_ sender: UIBarButtonItem) {
        notificationPublisher.sendNotification(title: "This is a title", subtitle: "My subtitle", body: "This is a body", badge: 1, delayInterval: 10)
    }
    
    //reset badge number when app is back in the foreground
    @objc func applicationDidBecomeActive(notification: NSNotification) {
//        print("active")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    //MARK: - Sync News
    
    @IBAction func syncNews(_ sender: UIBarButtonItem) {
        let newsLoader = NewsLoader()
        newsLoader.getJson()
        newsLoader.deleteNews()
        newsLoader.storeNews()
        newsRefresh()
    }
    
    
//MARK: - Refresh News
    
    func newsRefresh() {
        print("newsrefresh active")
        if Reachability.isConnectedToNetwork(){
            if self.segmentControl.selectedSegmentIndex == 0 {
                newsSync = NewsLoader().newsCore
            } else {
                newsSync = NewsLoader().newsCore
            }
            self.tableView.reloadData()
        } else {
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "Connection Error", message: "Please check if your internet connection is active.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler:{(action:UIAlertAction!) in
                if Reachability.isConnectedToNetwork(){
                    print("Internet Connection Available!")
                    self.viewDidAppear(true)
                } else{
                    self.viewDidAppear(true)
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
//MARK: - Delegate: Refresh News after Topic & Sources
    
    //required delegate func
    func popoverDismissed() {
//        self.navigationController?.dismiss(animated: true, completion: nil)
        newsRefresh()
    }
    
    
//MARK: - Segment Change Ctrl
    
    @objc fileprivate func handleSegmentChange() {
        //print(segmentControl.selectedSegmentIndex)
        switch segmentControl.selectedSegmentIndex {
        case 0:
            newsRefresh()
            tableView.reloadData()
        default:
            newsRefresh()
            tableView.reloadData()
        }
    }
    
    
//MARK: - Refresh Control
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    @objc func refreshContent() {
        perform(#selector(finishRefreshing), with: nil, afterDelay: 2.0)
        newsRefresh()
        print("refreshing")
    }
    
    @objc func finishRefreshing() {
        refreshControl.endRefreshing()
        print("refreshed")
    }
    
    //MARK: - Tableview
    
    //define row qty
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            if newsSync.count == 0 {
                //display empty bookmarks msg
                self.tableView.setEmptyMessage("Sem notícias")
            } else {
                self.tableView.restore()
            }
            return newsSync.count
        } else {
            if newsSync.count == 0 {
                //display empty bookmarks msg
                self.tableView.setEmptyMessage("Sem notícias")
            } else {
                self.tableView.restore()
            }
            return newsSync.count
        }
        

    }
    
    //create our cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //check for checkmarks
        retrieveHistory()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

//        let newsRow: NewsData
//        if segmentControl.selectedSegmentIndex == 0 {
//            newsRow = filteredData[indexPath.row]
//        } else {
//            newsRow = data[indexPath.row]
//        }

        //check if row is in history
        //print("readHistory is: \(readHistory)")
        if readHistory.contains(newsSync[indexPath.row][1] as! String) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        //set row title/subtitle
        cell.textLabel?.text = newsSync[indexPath.row][0] as? String
        cell.detailTextLabel?.text = newsSync[indexPath.row][3] as? String
        
        //set row img
        let image = UIImage(named: "placeholder.pdf")
        cell.imageView?.kf.indicatorType = .activity
        let scale = UIScreen.main.scale
        let processor = DownsamplingImageProcessor(size: CGSize(width: 60 * scale, height: 60 * scale)) |> CroppingImageProcessor(size: CGSize(width: 60, height: 60), anchor: CGPoint(x: 0, y: 0)) |> RoundCornerImageProcessor(cornerRadius: 5)
        let resource = ImageResource(downloadURL: URL(string: newsSync[indexPath.row][2] as! String )!, cacheKey: newsSync[indexPath.row][2] as? String)
        
//        if scale == 2.0 {
//            resource = ImageResource(downloadURL: URL(string: newsRow.img_src ?? String("http://paulocustodio.com/wukela/empty@2x.pdf"))!, cacheKey: newsRow.img_src)
//        } else if scale == 3.0 {
//            resource = ImageResource(downloadURL: URL(string: newsRow.img_src ?? String("http://paulocustodio.com/wukela/empty@3x.pdf"))!, cacheKey: newsRow.img_src)
//        }
        
        cell.imageView?.kf.setImage(
            with: resource,
            placeholder: image,
            options: [.processor(processor),
                      .scaleFactor(UIScreen.main.scale),
                      .transition(.fade(0.5)),
                      .cacheOriginalImage
            ])
//        {
//            result in
//            // `result` is either a `.success(RetrieveImageResult)` or a `.failure(KingfisherError)`
//            switch result {
//            case .success(let value):
//                // The image was set to image view:
//                print(value.image)
//
//                // From where the image was retrieved:
//                // - .none - Just downloaded.
//                // - .memory - Got from memory cache.
//                // - .disk - Got from disk cache.
//                print(value.cacheType)
//
//                // The source object which contains information like `url`.
//                print(value.source)
//
//            case .failure(let error):
//                print(error) // The error happens
//            }
//        }
        
        return cell
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print cell that was tapped on
        //print(indexPath.row)

        //set checkmark
//        let newsRow: NewsData
//        if segmentControl.selectedSegmentIndex == 0 {
//            newsRow = filteredData[indexPath.row]
//        } else {
//            newsRow = data[indexPath.row]
//        }
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        headlineRead = newsSync[indexPath.row][1] as! String
//        print("last selection was: \(headlineRead)")
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        markRead()
    }
    
//MARK: - Segue to WebViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segmentControl.selectedSegmentIndex == 0 {
            if segue.identifier == "getNews" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let destination = segue.destination as? WebViewController
                    destination?.headline = newsSync[indexPath.row][0] as! String
                    destination?.url = newsSync[indexPath.row][1] as! String
                    destination?.source = newsSync[indexPath.row][3] as! String
                    destination?.epoch = newsSync[indexPath.row][5] as! Double
                }
            }
        } else {
            if segue.identifier == "getNews" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let destination = segue.destination as? WebViewController
                    destination?.headline = newsSync[indexPath.row][0] as! String
                    destination?.url = newsSync[indexPath.row][1] as! String
                    destination?.source = newsSync[indexPath.row][3] as! String
                    destination?.epoch = newsSync[indexPath.row][5] as! Double
                }
            }
        }
    }
    
    
//MARK: - Mark as Read - CoreData
    
    func markRead(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "Read", in: managedContext)!
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(headlineRead, forKeyPath: "isRead")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
//MARK: - Retrieve Read History - CoreData
    
    func retrieveHistory() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Read")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            for data in result as! [NSManagedObject] {
                let viewRead = data.value(forKey: "isRead") as! String
                readHistory.append(viewRead)
                readHistory = Array(Set(readHistory))
            }
            //print(readHistory)

        } catch {
            print("Failed")
        }
    }
}

//extension UIView {
//    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor, colorThree: UIColor, colorFour: UIColor) {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor, colorThree.cgColor, colorFour.cgColor]
//        gradientLayer.locations = [0.0, 0.6 , 0.7 , 0.8]
//        gradientLayer.startPoint = CGPoint(x: 0.0 , y: 0.0)
//        gradientLayer.endPoint = CGPoint (x: 0.0 , y: 1.0)
//
//        layer.insertSublayer(gradientLayer, at: 0)
//    }
//}


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
