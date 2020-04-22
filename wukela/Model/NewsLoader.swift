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
//    var news = [NewsData]()
//    var filterNews = [NewsData]()
    
    var retrievedSource = ""
    var retrievedTopic = ""
    var newsBulk = [NewsData]()
    var newsCore = [[Any]]()
    var newCount = 0
    
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
    var jsonCount = 0
    
    //run our load & sort functions when our class NewsLoader is created
    init() {
        
        sourceCheck()
        topicCheck()
        
        if activeSources == ["","","","","","","","","","","","","",""] {
            print("no sources active")
        } else {
            appendNews()
            filterNews()
            
        }
    }
    
    //load our data
    public func getJson() {
        
        print("getJson")
        
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
                //print(data)
            } catch {
                print(error)
            }
        }
        
        //create json count
        jsonCount = newsBulk.count
//        print("count is \(jsonCount)")
        newCount = jsonCount
        
        newsBulk = self.newsBulk.sorted { $0.epoch > $1.epoch }
    }
    
    
    func getCount() -> Int {
        newCount = jsonCount
        return newCount
    }
    
    
//MARK: - Delete news in Coredata
    
    public func deleteNews() {
        
        print("deleteNews")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "NewsSync"))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
    
    
    //MARK: - Add Json to Coredata
    
    public func storeNews() {
        
        print("storeNews")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "NewsSync", in: managedContext)!
        
        for count in 0..<jsonCount {
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(newsBulk[count].headline, forKeyPath: "headlineSync")
            user.setValue(newsBulk[count].url_src, forKeyPath: "url_srcSync")
            //look out for empty img and set default
            let scale = UIScreen.main.scale
            if newsBulk[count].img_src == nil && scale == 1.0 {
                user.setValue("http://paulocustodio.com/wukela/empty.pdf", forKeyPath: "img_srcSync")
            } else if newsBulk[count].img_src == nil && scale == 2.0 {
                user.setValue("http://paulocustodio.com/wukela/empty@2x.pdf", forKeyPath: "img_srcSync")
            } else if newsBulk[count].img_src == nil && scale == 3.0 {
                user.setValue("http://paulocustodio.com/wukela/empty@3x.pdf", forKeyPath: "img_srcSync")
            } else {
                user.setValue(newsBulk[count].img_src, forKeyPath: "img_srcSync")
            }
            user.setValue(newsBulk[count].news_src, forKeyPath: "news_srcSync")
            user.setValue(newsBulk[count].cat, forKeyPath: "catSync")
            user.setValue(newsBulk[count].epoch, forKeyPath: "epochSync")
            user.setValue(count, forKeyPath: "countSync")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    //MARK: - Append Coredata to 2D Array
    
    public func appendNews() {
        
        print("appendNews")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsSync")
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {
                
                let headline = data.value(forKey: "headlineSync") as! String
                let url_src = data.value(forKey: "url_srcSync") as! String
                let img_src = data.value(forKey: "img_srcSync") as! String
                let news_src = data.value(forKey: "news_srcSync") as! String
                let cat = data.value(forKey: "catSync") as! String
                let epoch = data.value(forKey: "epochSync") as! Double
                let count = data.value(forKey: "countSync") as! Int
                
                //create 2d array
                newsCore.append([headline, url_src, img_src, news_src, cat, epoch, count])
                
                //sort 2d array
//                print(newsCore)
                newsCore = newsCore.sorted(by: {($0[6] as! Int) < ($1[6] as! Int) })
                
//                print(newsCore)
//                print(headline)
            }
        } catch {
            print("Failed")
        }

    }
    
    
    
    
    //MARK: - Check Coredata for active Sources
    
    public func sourceCheck() {
        
        print("sourcecheck")
        
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
    
    
    //MARK: - Check Coredata for active Topics
    
    public func topicCheck() {
        
        print("topiccheck")
        
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
    
    
    //MARK: - Filter array generated by Coredata
    
    public func filterNews() {
        
        print("filterNews")
        //filter news source based on what is available on the array generated by coredata
        //when user toggles news source off, it triggers coredata, then updates this list
        let foundSources = newsCore.filter { $0[3] as! String == activeSources[0] || $0[3] as! String == activeSources[1] || $0[3] as! String == activeSources[2] || $0[3] as! String == activeSources[3] || $0[3] as! String == activeSources[4] || $0[3] as! String == activeSources[5] || $0[3] as! String == activeSources[6] || $0[3] as! String == activeSources[7] || $0[3] as! String == activeSources[8] || $0[3] as! String == activeSources[9] || $0[3] as! String == activeSources[10] || $0[3] as! String == activeSources[11] || $0[3] as! String == activeSources[12] || $0[3] as! String == activeSources[13]}
        
        //mash all the filtered sources
        newsCore = foundSources
        
        //filter news sources based on active topics
        let foundTopics = newsCore.filter { $0[4] as! String == activeTopics[0] || $0[4] as! String == activeTopics[1] || $0[4] as! String == activeTopics[2] || $0[4] as! String == activeTopics[3] || $0[4] as! String == activeTopics[4] || $0[4] as! String == activeTopics[5] || $0[4] as! String == activeTopics[6]}
        
        newsCore = foundTopics
        
//        newsCore = self.newsCore.sorted { $0[5] > $1[5] }
        
//        //sort all news
//        news = self.news.sorted { $0.epoch > $1.epoch }
//
//        //filter recent news
//        let currentTime = NSDate().timeIntervalSince1970
//        let pastDay = currentTime - 86400
//        filterNews = self.news.filter { $0.epoch > pastDay }
    }
}

