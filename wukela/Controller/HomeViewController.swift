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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var refreshControl = UIRefreshControl()
    var data = [NewsData]()
    var filteredData = [NewsData]()

    //badge counter
    var latestCount = 0
    var oldCount = 0
    var newCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
//        bottomView.setGradientBackground(colorOne: UIColor(white: 1, alpha: 0), colorTwo: UIColor(named: "eightBkColor")!, colorThree: UIColor(named: "nineBkColor")!, colorFour: UIColor(named: "bkColor")!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //count new items
        
        print("viewwillappear")
        latestCount = NewsLoader().news.count
        cleanseCount()
        if segmentControl.selectedSegmentIndex == 0 {
            calculateCount()
            filteredData = RecentNewsLoader().news
            
        } else {
            calculateCount()
            data = NewsLoader().news
        }
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateCount()
    }
    
//MARK: - Segment Change Ctrl
    
    @objc fileprivate func handleSegmentChange() {
        //print(segmentControl.selectedSegmentIndex)
        switch segmentControl.selectedSegmentIndex {
        case 0:
            DispatchQueue.main.async {
                self.filteredData = RecentNewsLoader().news
                self.tableView.reloadData()
            }
            
        default:
            DispatchQueue.main.async {
                self.data = NewsLoader().news
                self.tableView.reloadData()
            }
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
        self.perform(#selector(finishRefreshing), with: nil, afterDelay: 1.0)
            if segmentControl.selectedSegmentIndex == 0 {
                filteredData = RecentNewsLoader().news
                tableView.reloadData()
            } else {
                data = NewsLoader().news
                tableView.reloadData()
            }
        print("refreshing")
    }
    
    @objc func finishRefreshing() {
        refreshControl.endRefreshing()
        print("refreshed")
    }
    
    //MARK: - Calculate Badge Count
    
    func calculateCount() {
        
        //get oldCount
        retrieveCount()
        
        //calculate new count
        newCount = latestCount - oldCount
        
        print("Latest count is \(latestCount)")
        print("Old count is \(oldCount)")
        print("New count is \(newCount)")
        
        //set badge value
        if let tabItems = tabBarController?.tabBar.items {
            let tabItemOne = tabItems[0]
            if newCount > 0 {
                tabItemOne.badgeValue = String(newCount)
            } else {
                tabItemOne.badgeValue = nil
            }
        }
    }
    
    //MARK: - Tableview
    
    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if segmentControl.selectedSegmentIndex == 0 {
            return filteredData.count
        } else {
            return data.count
        }
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let newsRow: NewsData
        
        if segmentControl.selectedSegmentIndex == 0 {
            newsRow = filteredData[indexPath.row]
        } else {
            newsRow = data[indexPath.row]
        }

        cell.textLabel?.text = newsRow.headline
        cell.detailTextLabel?.text = newsRow.news_src
        
        //let url = URL(string: newsRow.img_src)!
        let image = UIImage(named: "placeholder.pdf")
        cell.imageView?.kf.indicatorType = .activity
        
        let scale = UIScreen.main.scale

        let processor = DownsamplingImageProcessor(size: CGSize(width: 60 * scale, height: 60 * scale)) |> CroppingImageProcessor(size: CGSize(width: 60, height: 60), anchor: CGPoint(x: 0, y: 0)) |> RoundCornerImageProcessor(cornerRadius: 10)

        let resource = ImageResource(downloadURL: URL(string: newsRow.img_src ?? String("http://paulocustodio.com/wukela/empty.pdf"))!, cacheKey: newsRow.img_src)
        
        cell.imageView?.kf.setImage(
            with: resource,
            placeholder: image,
            options: [.processor(processor),
                      .transition(.fade(0.5))])
        {
            result in
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
    
//MARK: - Segue to WebViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getNews" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as? WebViewController
                destination?.url = data[indexPath.row].url_src!
                destination?.headline = data[indexPath.row].headline!
                destination?.source = data[indexPath.row].news_src!
            }
        }
    }
    
    //MARK: - Calculate new - CoreData
    
    func updateCount() {
        
        print("adding lastCount to coredata")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "Badge", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(latestCount, forKey: "lastCount")

        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
        //MARK: - Retrieve Count - CoreData
        
        func retrieveCount() {
            
            print("look up lastCount in coredata and store it as oldCount")

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Badge")
            do {
                let result = try managedContext.fetch(fetchRequest)
                
                //Loop over CoreData entities
                for data in result as! [NSManagedObject] {
                    oldCount = data.value(forKey: "lastCount") as! Int
                    print(oldCount)
                }
            } catch {
                print("Failed")
            }
        }
    
    //MARK: - Cleanse Coredata if there are more that 10 objects present
    
    func cleanseCount() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Badge")
        do {
            let count = try managedContext.count(for: fetchRequest)
            print("got this many objects in CD: \(count)")
            if count >= 10 {
                resetAllRecords(in: "Badge")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func resetAllRecords(in entity : String) // entity = Your_Entity_Name
    {

        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Badge")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
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
