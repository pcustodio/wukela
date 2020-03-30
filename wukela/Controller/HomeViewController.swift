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
    
    var refreshControl = UIRefreshControl()
    
    let data = NewsLoader().news
    
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
        return data.count
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let newsRow: NewsData
        newsRow = data[indexPath.row]
        
        cell.textLabel?.text = newsRow.headline
        cell.detailTextLabel?.text = newsRow.news_src
        
        let url = URL(string: newsRow.img_src)!
        let image = UIImage(named: "placeholder.pdf")
        cell.imageView?.kf.indicatorType = .activity
    
        let processor = DownsamplingImageProcessor(size: CGSize(width: 120, height: 120)) |> CroppingImageProcessor(size: CGSize(width: 60, height: 60), anchor: CGPoint(x: 0, y: 0)) |> RoundCornerImageProcessor(cornerRadius: 5)
        
        cell.imageView?.kf.setImage(with: url, placeholder: image, options: [.processor(processor), .transition(.fade(0.5))], completionHandler: { (image, error, cacheType, URL) in
            cell.setNeedsLayout()
        })
        
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
