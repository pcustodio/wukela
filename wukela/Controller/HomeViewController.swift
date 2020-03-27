//
//  HomeViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var newsPic: UIImageView!
    
    
    let data = NewsLoader().news
//    var newsURL : String = ""
    var picURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        getNews()
        
//        //remove extraneous empty cells
//        tableView.tableFooterView = UIView()
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
    }

    
//MARK: - Get image from url
    
    //Create a method with a completion handler to get the image data from your url
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    //Create a method to download the image (start the task)
    func downloadImage(from url: URL) {
        //print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            //print("Download Finished")
            DispatchQueue.main.async() {
                self.newsPic.image = UIImage(data: data)
            }
        }
    }

//MARK: - Get news function
    
    func getNews() {

        print(data[0].headline)
        print(data[0].url_src)
        print(data[0].img_src)
        print(data[0].news_src)
        print(data[0].cat)
        
        self.headlineLabel.text = data[0].headline
        self.sourceLabel.text = data[0].news_src
        //self.newsURL = data[0].url_src
        
        //get news photo
        self.picURL = data[0].img_src
        if let url = URL(string: self.picURL) {
            self.downloadImage(from: url)
        } else {
            print("No pic was found")
        }
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
