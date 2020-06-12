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

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellSubtitle: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RefreshTransitionListener {
    
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    

    var refreshControl = UIRefreshControl()
    
    //vars for history
    var headlineRead = ""
    var urlRead = ""
    var imgRead = ""
    var srcRead = ""
    var langRead = ""
    var catRead = ""
    var epochRead = 0.0
    var timeRead = 0.0
    
    var readHistory = [String]()
    
    var newsSync = [[Any]]()
    var historySync : [NSManagedObject] = []
    
    
//MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload")
        
        // set observer to refresh news
        NotificationCenter.default.addObserver(self, selector: #selector(newsRefresh), name: UIApplication.willEnterForegroundNotification, object: nil)
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
        
        //refresh control
        addRefreshControl()
        
        //set cell height
        self.tableView.rowHeight = 80;
        
        //segments
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        
        //customise navigation bar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.backgroundColor = UIColor(named: "bkColor")
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
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
    
    
    //MARK: - Sync News
    
    @IBAction func syncNewsBtn(_ sender: UIBarButtonItem) {
        
        if let window = view.window {
            
            //insert background
            let subView = UIView(frame: window.frame)
            subView.backgroundColor = UIColor(named: "syncDark")
            subView.alpha = 0
            window.addSubview(subView)
            UIView.animate(withDuration: 0.2, animations: { subView.alpha = 0.9 })

            //insert activity indicator
            let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
            actInd.frame = CGRect(x: window.center.x - 20, y: window.center.y - 60, width: 40.0, height: 40.0);
            actInd.hidesWhenStopped = true
            actInd.style =
                UIActivityIndicatorView.Style.large
            actInd.color = UIColor(named: "loaderLast")
            actInd.alpha = 0
            window.addSubview(actInd)
            actInd.startAnimating()
            UIView.animate(withDuration: 0.5, animations: { actInd.alpha = 1.0 })
            
            //insert label
            let mainSyncLabel = UILabel(frame: window.frame)
            mainSyncLabel.center = CGPoint(x: actInd.center.x, y: actInd.center.y + 60)
            mainSyncLabel.textColor = UIColor.white
            mainSyncLabel.alpha = 0
            mainSyncLabel.text = NSLocalizedString("Sync", comment: "")
            mainSyncLabel.textAlignment = .center
            mainSyncLabel.font = UIFont(name: "ProximaNova-Light", size: 25)
            window.addSubview(mainSyncLabel)
            UIView.animate(withDuration: 0.5, animations: { mainSyncLabel.alpha = 1.0 })
            
            //insert sublabel
            let subSyncLabel = UILabel(frame: window.frame)
            subSyncLabel.center = CGPoint(x: mainSyncLabel.center.x, y: mainSyncLabel.center.y + 30)
            subSyncLabel.textColor = UIColor.white
            subSyncLabel.alpha = 0
            subSyncLabel.text = NSLocalizedString("Wait", comment: "")
            subSyncLabel.textAlignment = .center
            subSyncLabel.font = UIFont(name: "ProximaNova-Bold", size: 12)
            subSyncLabel.textColor = UIColor(named: "subtitleColor")
            window.addSubview(subSyncLabel)
            UIView.animate(withDuration: 1.0, animations: { subSyncLabel.alpha = 1.0 })

            //sync news
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let newsLoader = NewsLoader()
                newsLoader.getJson()
                newsLoader.deleteNews()
                newsLoader.storeNews()
                self.newsRefresh()
                
                UIView.animate(withDuration: 1.0, animations: { subView.alpha = 0.0 }) { (done: Bool) in
                    subView.removeFromSuperview()
                }
                UIView.animate(withDuration: 0.5, animations: { actInd.alpha = 0.0 }) { (done: Bool) in
                    actInd.stopAnimating()
                }
                UIView.animate(withDuration: 0.5, animations: { mainSyncLabel.alpha = 0.0 }) { (done: Bool) in
                    mainSyncLabel.removeFromSuperview()
                }
                UIView.animate(withDuration: 0.5, animations: { subSyncLabel.alpha = 0.0 }) { (done: Bool) in
                    subSyncLabel.removeFromSuperview()
                }
            }
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
        tableView.reloadData()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeTableViewCell
        
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
            cell.cellTitle?.text = newsSync[indexPath.row][0] as? String
            
            //set source
            cell.cellSubtitle?.text = newsSync[indexPath.row][3] as? String

            //set row img
            let image = UIImage(named: "placeholder.pdf")
            cell.cellImage?.kf.indicatorType = .activity
            cell.cellImage.layer.cornerRadius = 5.0
            
            
//            let resource = ImageResource(downloadURL: (URL(string: newsSync[indexPath.row][2] as! String ) ??  URL(string:"https://wukela.app/assets/empty@3x.pdf"))!, cacheKey: newsSync[indexPath.row][2] as? String)

            let lang = newsSync[indexPath.row][7] as! String
            let source = newsSync[indexPath.row][3] as! String
            
            //if news item is in arabic
            if lang == "Arabic" {
                cell.cellTitle?.textAlignment = NSTextAlignment.right
                cell.cellSubtitle?.textAlignment = NSTextAlignment.right
                let imgURL = (newsSync[indexPath.row][2] as! String).addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
                let resource = ImageResource(downloadURL: (URL(string: imgURL! ) ??  URL(string:"https://wukela.app/assets/empty@3x.pdf"))!, cacheKey: imgURL)
                cell.cellImage?.kf.setImage(
                    with: resource,
                    placeholder: image,
                    options: [.scaleFactor(UIScreen.main.scale),
                              .transition(.fade(0.5)),
                              .cacheOriginalImage
                    ]
                )
                
            //else news item is another language
            } else {
                cell.cellTitle?.textAlignment = NSTextAlignment.left
                cell.cellSubtitle?.textAlignment = NSTextAlignment.left
                let resource = ImageResource(downloadURL: (URL(string: newsSync[indexPath.row][2] as! String ) ??  URL(string:"https://wukela.app/assets/empty@3x.pdf"))!, cacheKey: newsSync[indexPath.row][2] as? String)
                cell.cellImage?.kf.setImage(
                    with: resource,
                    placeholder: image,
                    options: [.scaleFactor(UIScreen.main.scale),
                              .transition(.fade(0.5)),
                              .cacheOriginalImage
                    ]
                )
            }
            
            //if news item source is El Khabar
            if source == "El Khabar" {
                cell.cellTitle?.textAlignment = NSTextAlignment.right
                cell.cellSubtitle?.textAlignment = NSTextAlignment.right
                let resource = ImageResource(downloadURL: (URL(string: newsSync[indexPath.row][2] as! String ) ??  URL(string:"https://wukela.app/assets/empty@3x.pdf"))!, cacheKey: newsSync[indexPath.row][2] as? String)
                cell.cellImage?.kf.setImage(
                    with: resource,
                    placeholder: image,
                    options: [.scaleFactor(UIScreen.main.scale),
                              .transition(.fade(0.5)),
                              .cacheOriginalImage
                    ]
                )
            }

        } else {
            //set tableview based on history saved in coredata
            
            //clear checkmarks
            cell.accessoryType = .none
            
            //aligh coredata with indexpath
            let historySynced = historySync[indexPath.row]
            
            //get headline
            cell.cellTitle?.text = historySynced.value(forKeyPath: "headlineRead") as? String
            
            //get time read
            //convert epoch with dateformatter
            let unixTimestamp = historySynced.value(forKeyPath: "timeRead")
            let date = Date(timeIntervalSince1970: unixTimestamp as! TimeInterval)
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                cell.cellSubtitle?.text = "Hoje"
            } else if calendar.isDateInYesterday(date) {
                cell.cellSubtitle?.text = "Ontem"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.locale = Locale.init(identifier: Locale.preferredLanguages[1])
                dateFormatter.setLocalizedDateFormatFromTemplate("ddMMMM")
                let strDate = dateFormatter.string(from: date)
                cell.cellSubtitle?.text = strDate
            }
            
            //set row img
            let image = UIImage(named: "placeholder.pdf")
            cell.cellImage?.kf.indicatorType = .activity
            let resource = ImageResource(downloadURL: URL(string: historySynced.value(forKeyPath: "imgRead") as! String )!, cacheKey: historySynced.value(forKeyPath: "imgRead") as? String)
            cell.cellImage?.kf.setImage(
                with: resource,
                placeholder: image,
                options: [.scaleFactor(UIScreen.main.scale),
                          .transition(.fade(0.5)),
                          .cacheOriginalImage
                ]
            )
            
            //set text alignment
            langRead = historySynced.value(forKeyPath: "langRead") as! String
            if langRead == "Arabic" {
                cell.cellTitle?.textAlignment = NSTextAlignment.right
                cell.cellSubtitle?.textAlignment = NSTextAlignment.right
            } else {
                cell.cellTitle?.textAlignment = NSTextAlignment.left
                cell.cellSubtitle?.textAlignment = NSTextAlignment.left
            }
            
        }
        
        return cell
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 0 {
            
            //delay check presentation to avoid ui jump
            _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            })
            
            //set vars for history
            headlineRead = newsSync[indexPath.row][0] as! String
            srcRead = newsSync[indexPath.row][3] as! String
            catRead = newsSync[indexPath.row][4] as! String
            epochRead = newsSync[indexPath.row][8] as! Double
            timeRead = newsSync[indexPath.row][8] as! Double
            langRead = newsSync[indexPath.row][7] as! String
            urlRead = newsSync[indexPath.row][1] as! String
            
            //perform language checks for imgRead var so it can pass along correct img url
            //if news item is in arabic
            if langRead == "Arabic" {
                imgRead = (newsSync[indexPath.row][2] as! String).addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
            //else news item is another language
            } else {
                imgRead = newsSync[indexPath.row][2] as! String
            }
            //if news item source is El Khabar
            if srcRead == "El Khabar" {
                imgRead = newsSync[indexPath.row][2] as! String
            }

            self.tableView.deselectRow(at: indexPath, animated: true)
            
            //set vars as Coredata
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
                    destination?.epoch = newsSync[indexPath.row][8] as! Double
                    destination?.lang = newsSync[indexPath.row][7] as! String
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
                    destination?.lang = (historySynced.value(forKeyPath: "langRead") as? String)!
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
        user.setValue(langRead, forKeyPath: "langRead")
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
