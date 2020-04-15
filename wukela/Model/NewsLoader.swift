//
//  NewsLoader.swift
//  wukela
//
//  Created by Paulo Custódio on 26/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

//load data from json and turn it into my data structure on Dictionary.swift
class NewsLoader {
    
    //store all the data that is retrieved from json file
    var news = [NewsData]()
    var filterNews = [NewsData]()
    var latestCount = 0
    
    var retrievedSource = ""
    var retrievedTopic = ""
    var newsBulk = [NewsData]()
    
    let sources = ["Jornal Notícias",
                   "O País",
                   "Verdade",
                   "Savana",
                   "Jornal Angola",
                   "Novo Jornal",
                   "Folha 8",
                   "AngoNotícias",
                   "A Semana",
                   "Expresso das Ilhas",
                   "A Nação",
                   "O Democrata",
                   "Novas de Guiné Bissau",
                   "Público"]
    
    let categories = ["Sociedade",
                  "Desporto",
                  "Economia",
                  "Política",
                  "Cultura",
                  "Ciência e Tecnologia",
                  "Opinião"]
    
    var activeSources = ["","","","","","","","","","","","","",""]
    var activeTopics = ["","","","","","",""]
    
    //run our load & sort functions when our class NewsLoader is created
    init() {
        //check if user activated any sources
        sourceCheck()
        //check if user activated any topics
        topicCheck()
        //stop loading json if user has no sources or topics active
        if activeSources == ["","","","","","","","","","","","","",""] || activeTopics == ["","","","","","",""] {
            print("we can stop here")
        } else {
            load()
            filterSourcesAndTopics()
        }
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
                newsBulk = dataFromJson
                print(data)
            } catch {
                print(error)
            }
        }
    }
    
    
//MARK: - Check Coredata for active sources
    
    func sourceCheck() {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSources")
        do {
            let result = try managedContext.fetch(fetchRequest)

            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {
                
                //get active sources from coredata
                retrievedSource = data.value(forKey: "isActiveSource") as! String
                
                //loop over active sources and add them to array
                for source in sources {
                    if retrievedSource == source {
                        activeSources.insert(retrievedSource, at: 0)
                    }
                    //print(activeSources)
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    
//MARK: - Check Coredata for active topics
    
    func topicCheck() {
        //check Coredata for active news
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveTopics")
        do {
            let result = try managedContext.fetch(fetchRequest)

            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {
                
                //loop over active topics
                retrievedTopic = data.value(forKey: "isActiveTopic") as! String
                
                for category in categories {
                    if retrievedTopic == category {
                        activeTopics.insert(retrievedTopic, at: 0)
                    }
                }
            }
            //print("active topics are: \(activeTopics)")
        } catch {
            print("Failed")
        }
    }
    
    
//MARK: - Filter json based on array generated by coredata
    
    func filterSourcesAndTopics() {
        //filter news source based on what is available on the array generated by coredata
        //when user toggles news source off, it triggers coredata, then updates this list
        let foundSources = newsBulk.filter { $0.news_src == activeSources[0] || $0.news_src == activeSources[1] || $0.news_src == activeSources[2] || $0.news_src == activeSources[3] || $0.news_src == activeSources[4] || $0.news_src == activeSources[5] || $0.news_src == activeSources[6] || $0.news_src == activeSources[7] || $0.news_src == activeSources[8] || $0.news_src == activeSources[9] || $0.news_src == activeSources[10] || $0.news_src == activeSources[11] || $0.news_src == activeSources[12] || $0.news_src == activeSources[13]}
        
        //mash all the filtered sources
        let newsSources = foundSources

        //filter news sources based on active topics

        let foundTopics = newsSources.filter { $0.cat == activeTopics[0] || $0.cat == activeTopics[1] || $0.cat == activeTopics[2] || $0.cat == activeTopics[3] || $0.cat == activeTopics[4] || $0.cat == activeTopics[5] || $0.cat == activeTopics[6]}

        news = foundTopics
        
        //sort all news
        news = self.news.sorted { $0.epoch > $1.epoch }
        
        //filter recent news
        let currentTime = NSDate().timeIntervalSince1970
        let pastDay = currentTime - 86400
        filterNews = self.news.filter { $0.epoch > pastDay }
    }
}

