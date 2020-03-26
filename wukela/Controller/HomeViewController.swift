//
//  HomeViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var newsPic: UIImageView!
    
    
    let data = NewsLoader().news
    var newsURL : String = ""
    var picURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        getNews()
    }
    
//    @IBAction func openUrl(_ sender: UIButton) {
//        //send to WebViewController
//        //self.performSegue(withIdentifier: "goToURL", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "goToURL" {
            // Pass the selected object to the new view controller.
            let destinationVC = segue.destination as! WebViewController
            destinationVC.url = URL(string: newsURL)
        }
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
        
        self.headlineLabel.text = data[0].headline
        self.sourceLabel.text = "Jornal Notícias"
        self.newsURL = data[0].url_src
        
        //get news photo
        self.picURL = data[0].img_src
        if let url = URL(string: self.picURL) {
            self.downloadImage(from: url)
        } else {
            print("No pic was found")
        }
    
    }
    

}
