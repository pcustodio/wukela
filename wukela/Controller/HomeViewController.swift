//
//  HomeViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var refreshControl = UIRefreshControl()
    
    let data = NewsLoader().news
    let filteredData = RecentNewsLoader().news
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()
        
        //hide separator line
        self.tableView.separatorColor = .clear;
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //set cell height
        self.tableView.rowHeight = 80;
        
        addRefreshControl()
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        
//        bottomView.setGradientBackground(colorOne: UIColor(white: 1, alpha: 0), colorTwo: UIColor(named: "eightBkColor")!, colorThree: UIColor(named: "nineBkColor")!, colorFour: UIColor(named: "bkColor")!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewwillappear")

        //tableView.reloadData()
        
    }

    
    @objc fileprivate func handleSegmentChange() {
        //print(segmentControl.selectedSegmentIndex)
        switch segmentControl.selectedSegmentIndex {
        case 0:
            tableView.reloadData()
        default:
            tableView.reloadData()
        }
    }
    
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
        tableView.reloadData()
        print("refreshing")
    }
    
    @objc func finishRefreshing() {
        refreshControl.endRefreshing()
        print("refreshed")
    }
    
    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
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
            
//            //get epoch and current time
//            let currentTime = NSDate().timeIntervalSince1970
//            let pastHour = currentTime - 3600
//            print("today starts at \(pastHour)")
            
            //if rows epoch occured in the past hour
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
            // `result` is either a `.success(RetrieveImageResult)` or a `.failure(KingfisherError)`
            switch result {
            case .success(let value):
                // The image was set to image view:
                print(value.image)
                
                // From where the image was retrieved:
                // - .none - Just downloaded.
                // - .memory - Got from memory cache.
                // - .disk - Got from disk cache.
                print(value.cacheType)
                
                // The source object which contains information like `url`.
                print(value.source)
                
            case .failure(let error):
                print(error) // The error happens
            }
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
