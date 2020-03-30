//
//  HomeViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var refreshControl = UIRefreshControl()
    
    let data = NewsLoader().news

    let timeSplit = ""
    let currentSegment = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataNew = data[0].epoch
        let currentTime = NSDate().timeIntervalSince1970
        print(dataNew)
        print(currentTime)
        let timeSplit = currentTime - dataNew
        print(timeSplit)
        
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
    
}

//MARK: - TableView

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        if segmentControl.selectedSegmentIndex == 0 {
            return data.count
        } else {
            return 1
        }
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if segmentControl.selectedSegmentIndex == 0 {
            let newsRow: NewsData
            newsRow = data[indexPath.row]
            
            cell.textLabel?.text = newsRow.headline
            cell.detailTextLabel?.text = newsRow.news_src
            
            //let url = URL(string: newsRow.img_src)!
            let image = UIImage(named: "placeholder.pdf")
            cell.imageView?.kf.indicatorType = .activity
        
            let processor = DownsamplingImageProcessor(size: CGSize(width: 120, height: 120)) |> CroppingImageProcessor(size: CGSize(width: 60, height: 60), anchor: CGPoint(x: 0, y: 0)) |> RoundCornerImageProcessor(cornerRadius: 5)
            
            let resource = ImageResource(downloadURL: URL(string: newsRow.img_src)!, cacheKey: newsRow.img_src)
            
            cell.imageView?.kf.setImage(with: resource, placeholder: image, options: [.processor(processor), .transition(.fade(0.5))]) { result in
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
        } else {
            print("no table")
            cell.textLabel?.text = "test title"
            cell.imageView?.image = UIImage(named: "placeholder")
            cell.detailTextLabel?.text = "test detail"
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
                destination?.url = data[indexPath.row].url_src
                destination?.headline = data[indexPath.row].headline
                destination?.source = data[indexPath.row].news_src
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
