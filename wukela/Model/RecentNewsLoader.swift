//
//  RecentNewsLoader.swift
//  wukela
//
//  Created by Paulo Custódio on 31/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

//load data from json and turn it into my data structure on Dictionary.swift
public class RecentNewsLoader {
    
    //store all the data that is retrieved from json file
    var news = [NewsData]()
    
    
    var retrievedData = ""
    
    var activeSources = ["","",""]
    
    //run our load & sort functions when our class DictionaryLoader is created
    init() {
        load()
        //sort()
        filtered()
    }
    
    //load our data
    func load() {
        //access file location of local json file
        //if file is accessed code inside is run
        if let fileLocation = URL(string : "http://paulocustodio.com/scraper/jornalnoticias_done.json") {
            //run do catch in case of an error
            do {
                //try to get data from json file
                let data = try Data(contentsOf: fileLocation)
                //decode our json
                let jsonDecoder = JSONDecoder()
                //get data from json file using decoder
                let dataFromJson = try jsonDecoder.decode([NewsData].self, from: data)
                //set it to out dictionary array (line 16)
                let newsBulk = dataFromJson
                
                //check Coredata for active news
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedContext = appDelegate!.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSource")
                do {
                    let result = try managedContext.fetch(fetchRequest)

                    //Loop over CoreData entities
                    for data in result as! [NSManagedObject] {

                        retrievedData = data.value(forKey: "isActive") as! String
                        //print(retrievedData)
                        
                        //insert coredata into array in position
                        if retrievedData == "Jornal Notícias" {
                            activeSources.insert(retrievedData, at: 0)
                        } else if retrievedData == "O País" {
                            activeSources.insert(retrievedData, at: 1)
                        } else if retrievedData == "Verdade" {
                            activeSources.insert(retrievedData, at: 1)
                        }
                        
                        //print(activeSources)
                    }
                } catch {
                    print("Failed")
                }
                
                //filter news source based on what is available on the array generated by coredata
                //when user toggles news source off, it triggers coredata, then updates this list
                let checkSourceOne = newsBulk.filter { $0.news_src == activeSources[0]}
                let checkSourceTwo = newsBulk.filter { $0.news_src == activeSources[1]}
                let checkSourceThree = newsBulk.filter { $0.news_src == activeSources[2]}
                
                //and then mash all the filtered news sources
                news = checkSourceThree + checkSourceTwo + checkSourceOne
                
                //sort (may be failing)
                news = self.news.sorted { $0.epoch > $1.epoch }
                
                print(data)
            } catch {
                print(error)
            }
            
        }
        
    }
    
    //sort our data
    //    func sort() {
    //        //sort by pt String field in ascending sequence (alphabetically) and ignore accents
    //        self.news = self.news.sorted { $0.headline.localizedCaseInsensitiveCompare($1.headline) == ComparisonResult.orderedAscending }
    //    }
    
    func filtered() {
        //sort by pt String field in ascending sequence (alphabetically) and ignore accents
        let currentTime = NSDate().timeIntervalSince1970
        let pastDay = currentTime - 86400
        print("today starts at \(pastDay)")
        self.news = self.news.filter { $0.epoch > pastDay }
    }
    
    //sort our data
    func sort() {
        //sort by pt String field in ascending sequence (alphabetically) and ignore accents
        self.news = self.news.sorted { $0.epoch > $1.epoch }
    }
    
    
    
}