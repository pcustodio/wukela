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
    @IBOutlet var syncNews: UIBarButtonItem!
    
    var refreshControl = UIRefreshControl()
    
    var headlineRead = ""
    var urlRead = ""
    var imgRead = ""
    var srcRead = ""
    var catRead = ""
    var epochRead = 0.0
    var timeRead = 0.0
    
    var readHistory = [String]()
    
//    private let notificationPublisher = NotificationPublisher()
    
    var newsSync = [[Any]]()
    var historySync : [NSManagedObject] = []
    
    
//MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload")
        
        // set observer to refresh news
//        NotificationCenter.default.addObserver(self, selector: #selector(newsRefresh), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newsRefresh), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        //implement the refresh listener
        RefreshTransitionMediator.instance.setListener(listener: self)
        
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
        navBarAppearance.shadowColor = .clear
        navBarAppearance.backgroundColor = UIColor(named: "bkColor")
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
//        bottomView.setGradientBackground(colorOne: UIColor(white: 1, alpha: 0), colorTwo: UIColor(named: "eightBkColor")!, colorThree: UIColor(named: "nineBkColor")!, colorFour: UIColor(named: "bkColor")!)
            }
    
    
//MARK: - viewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        print("viewDidAppear")

        //get checkmarks
        retrieveHistory()
        
        //check for  1st launch refresh
        _ = isAppAlreadyLaunchedOnce()

    }
    
    
//MARK: - Check 1st load
    
    //check for 1st load
    public func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")

            newsRefresh()
            return false
        }
    }
//MARK: - Local Notifications
    
//    @IBAction func notifyBtn(_ sender: UIBarButtonItem) {
//        notificationPublisher.sendNotification(title: "This is a title", subtitle: "My subtitle", body: "This is a body", badge: 1, delayInterval: 10)
//    }
    
    //reset badge number when app is back in the foreground
    @objc func updateBadge(notification: NSNotification) {
//        print("active")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    //MARK: - Sync News
    
    @IBAction func syncNews(_ sender: UIBarButtonItem) {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.startAnimating()
        self.navigationController!.navigationBar.layer.zPosition = -1
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setLeftBarButton(barButton, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newsLoader = NewsLoader()
            newsLoader.getJson()
            newsLoader.deleteNews()
            newsLoader.storeNews()
            self.newsRefresh()
            activityIndicator.stopAnimating()
            self.navigationItem.setLeftBarButton(self.syncNews, animated: true)
        }
        


        
    }
    
    
//MARK: - Refresh News
    
    @objc func newsRefresh() {
        print("newsrefresh active")
        if Reachability.isConnectedToNetwork(){
            if self.segmentControl.selectedSegmentIndex == 0 {
                newsSync = NewsLoader().newsCore
//            } else {
//                newsSync = NewsLoader().newsRead
                
            }
            //avoid flickering
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
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
        newsRefresh()
        print("transistion listened to")
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
                self.tableView.setEmptyMessage("Sem artigos")
            } else {
                self.tableView.restore()
            }
            return newsSync.count
        } else {
            if historySync.count == 0 {
                //display empty bookmarks msg
                self.tableView.setEmptyMessage("Sem artigos")
            } else {
                self.tableView.restore()
            }
            return historySync.count
        }
    }
    
    //create our cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            //check for checkmarks
            retrieveHistory()

            //check if row is in history
            if readHistory.contains(newsSync[indexPath.row][0] as! String) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            //set headline
            cell.textLabel?.text = newsSync[indexPath.row][0] as? String
            
            //set source
            cell.detailTextLabel?.text = newsSync[indexPath.row][3] as? String
            
            //set row img
            let image = UIImage(named: "placeholder.pdf")
            cell.imageView?.kf.indicatorType = .activity
            let scale = UIScreen.main.scale
            let processor = DownsamplingImageProcessor(size: CGSize(width: 60 * scale, height: 60 * scale)) |> CroppingImageProcessor(size: CGSize(width: 60, height: 60), anchor: CGPoint(x: 0, y: 0)) |> RoundCornerImageProcessor(cornerRadius: 5)
            let resource = ImageResource(downloadURL: (URL(string: newsSync[indexPath.row][2] as! String ) ??  URL(string:"http://paulocustodio.com/wukela/empty.pdf"))!, cacheKey: newsSync[indexPath.row][2] as? String)
            cell.imageView?.kf.setImage(
                with: resource,
                placeholder: image,
                options: [.processor(processor),
                          .scaleFactor(UIScreen.main.scale),
                          .transition(.fade(0.5)),
                          .cacheOriginalImage
                ]
            )
        } else {
            //set tableview based on history saved in coredata
            
            //clear checkmarks
            cell.accessoryType = .none
            
            //aligh coredata with indexpath
            let historySynced = historySync[indexPath.row]
            
            //get headline
            cell.textLabel?.text = historySynced.value(forKeyPath: "headlineRead") as? String
            
            //get time read
            //convert epoch with dateformatter
            let unixTimestamp = historySynced.value(forKeyPath: "timeRead")
            let date = Date(timeIntervalSince1970: unixTimestamp as! TimeInterval)
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                cell.detailTextLabel?.text = "Hoje"
            } else if calendar.isDateInYesterday(date) {
                cell.detailTextLabel?.text = "Ontem"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.locale = Locale.init(identifier: Locale.preferredLanguages[1])
                dateFormatter.setLocalizedDateFormatFromTemplate("ddMMMM")
                let strDate = dateFormatter.string(from: date)
                cell.detailTextLabel?.text = strDate
            }
            
            //set row img
            let image = UIImage(named: "placeholder.pdf")
            cell.imageView?.kf.indicatorType = .activity
            let scale = UIScreen.main.scale
            let processor = DownsamplingImageProcessor(size: CGSize(width: 60 * scale, height: 60 * scale)) |> CroppingImageProcessor(size: CGSize(width: 60, height: 60), anchor: CGPoint(x: 0, y: 0)) |> RoundCornerImageProcessor(cornerRadius: 5)
            let resource = ImageResource(downloadURL: URL(string: historySynced.value(forKeyPath: "imgRead") as! String )!, cacheKey: historySynced.value(forKeyPath: "imgRead") as? String)
            cell.imageView?.kf.setImage(
                with: resource,
                placeholder: image,
                options: [.processor(processor),
                          .scaleFactor(UIScreen.main.scale),
                          .transition(.fade(0.5)),
                          .cacheOriginalImage
                ]
            )
        }
        
        return cell
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 0 {

            _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            })
            
            headlineRead = newsSync[indexPath.row][0] as! String
            urlRead = newsSync[indexPath.row][1] as! String
            imgRead = newsSync[indexPath.row][2] as! String
            srcRead = newsSync[indexPath.row][3] as! String
            catRead = newsSync[indexPath.row][4] as! String
            epochRead = newsSync[indexPath.row][5] as! Double
            timeRead = newsSync[indexPath.row][5] as! Double

            self.tableView.deselectRow(at: indexPath, animated: true)
            
            markRead()
        } else {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
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
                    destination?.img = newsSync[indexPath.row][2] as! String
                }
            }
        } else {
            if segue.identifier == "getNews" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let historySynced = historySync[indexPath.row]
                    let destination = segue.destination as? WebViewController
                    destination?.headline = (historySynced.value(forKeyPath: "headlineRead") as? String)!
                    destination?.url = (historySynced.value(forKeyPath: "urlRead") as? String)!
                    destination?.source = (historySynced.value(forKeyPath: "srcRead") as? String)!
                    destination?.epoch = (historySynced.value(forKeyPath: "epochRead") as? Double)!
                    destination?.img = (historySynced.value(forKeyPath: "imgRead") as? String)!
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
        user.setValue(headlineRead, forKeyPath: "headlineRead")
        user.setValue(urlRead, forKeyPath: "urlRead")
        user.setValue(imgRead, forKeyPath: "imgRead")
        user.setValue(srcRead, forKeyPath: "srcRead")
        user.setValue(catRead, forKeyPath: "catRead")
        user.setValue(epochRead, forKeyPath: "epochRead")
        user.setValue(NSDate().timeIntervalSince1970, forKeyPath: "timeRead")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
//MARK: - Retrieve Read History - CoreData
    
    func retrieveHistory() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
              return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Read")
        
        do {
            historySync = try managedContext.fetch(fetchRequest).reversed()
            
            for data in historySync {
                let viewHeadlineRead = data.value(forKey: "headlineRead") as! String
                readHistory.append(viewHeadlineRead)
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
