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

        self.headlineLabel.text = "Réus do caso LAM “apanham” 12 e 14 anos de prisão"
        self.sourceLabel.text = "Jornal Notícias"
        self.newsURL = "https://jornalnoticias.co.mz/index.php/sociedade/96417-reus-do-caso-lam-apanham-12-e-14-anos-de-prisao"
        
        //get news photo
        self.picURL = "https://jornalnoticias.co.mz/images/ANO-2020/MARCO/CASO-LAM-in.gif"
        if let url = URL(string: self.picURL) {
            self.downloadImage(from: url)
        } else {
            print("No pic was found")
        }
    
    }
    

}
