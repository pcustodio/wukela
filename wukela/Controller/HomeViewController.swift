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
    
    let data = NewsLoader().news
//    var newsURL : String = ""
    var picURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
//        //remove extraneous empty cells
//        tableView.tableFooterView = UIView()
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        
        let newsRow: NewsData
        newsRow = data[indexPath.row]
        
        cell.textLabel?.text = newsRow.headline
        cell.detailTextLabel?.text = newsRow.news_src
        
        let url = URL(string: newsRow.img_src)!
        cell.imageView?.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 15)
        cell.imageView?.kf.setImage(with: url, options: [.processor(processor), .transition(.fade(0.2))], completionHandler: { (image, error, cacheType, URL) in
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
            }
        }
    }
}
