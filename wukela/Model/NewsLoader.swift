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
    
    //array containing json
    var newsJson = [NewsData]()
    
    //array containing coredata
    var newsCore = [[Any]]()
    
    let sources = ["Algérie 360",
                   "Echorouk",
                   "El Khabar",
                   "Observ'Algérie",
                   "Folha 8",
                   "Jornal de Angola",
                   "Novo Jornal",
                   "O País (Angola)",
                   "La Nation",
                   "L'Evénement Précis",
                   "Quotidien le Matinal",
                   "Mmegi",
                   "The Midweek Sun",
                   "The Voice",
                   "Burkina 24",
                   "Le Faso",
                   "Sidwaya",
                   "Itara Burundi",
                   "Iwacu",
                   "Nawe",
                   "Actu Cameroun",
                   "Cameroon Online",
                   "Cameroon Tribune",
                   "Journal du Cameroun",
                   "A Nação",
                   "A Semana",
                   "Expresso das Ilhas",
                   "Akhbar El Yom",
                   "Al-Ahram",
                   "Al Wafd",
                   "Egypt Today",
                   "El Balad",
                   "Youm7",
                   "Jornal Notícias",
                   "O País",
                   "Verdade",
                   "Carta de Moçambique",
                   "Jornal Txopela",
                   "Club of Mozambique",
                   "The Guardian",
                   "Punch",
                   "The Nation",
                   "Vanguard",
                   "Citizen",
                   "Herald",
                   "Isolezwe",
                   "Mail & Guardian",
                   "Sowetan",
                   "Times",
                   "Daily News"]
    
    let categories = ["Sociedade",
                      "Desporto",
                      "Economia e Negócios",
                      "Política",
                      "Cultura e Entretenimento",
                      "Ciência e Tecnologia",
                      "Opinião"]
    
    //array with sources coredata
    var retrievedSource = ""
    var activeSources = ["","","","","","","","","","","","","","","","",""]
    
    //array with topics coredata
    var retrievedTopic = ""
    var activeTopics = ["","","","","","",""]
    
    //count json items
    var jsonCount = 0
    
    //run when NewsLoader is created
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
    
    //get our json data
    public func getJson() {
        
        print("getJson")
        
        //access file location of local json file
        //if file is accessed code inside is run
        if let fileLocation = URL(string : "http://paulocustodio.com/scraper/news_done.json") {
            //run do catch in case of an error
            do {
                //try to get data from json file
                let data = try Data(contentsOf: fileLocation)
                //decode our json
                let jsonDecoder = JSONDecoder()
                //get data from json file using decoder
                let dataFromJson = try jsonDecoder.decode([NewsData].self, from: data)
                newsJson = dataFromJson
            } catch {
                print(error)
            }
        }
        
        //create json count
        jsonCount = newsJson.count
        
        //sort json
        newsJson = self.newsJson.sorted { $0.epoch > $1.epoch }
    }
    
    
    
//MARK: - Delete news in NewsSync Coredata
    
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
    
    
    //MARK: - Add Json to NewsSync Coredata
    
    public func storeNews() {
        
        print("storeNews: store json data in Coredata")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "NewsSync", in: managedContext)!
        
        //loop over total elements in json
        for count in 0..<jsonCount {
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(newsJson[count].headline, forKeyPath: "headlineSync")
            user.setValue(newsJson[count].url_src, forKeyPath: "url_srcSync")
            //look out for empty img and set default
            let scale = UIScreen.main.scale
            if newsJson[count].img_src == nil && scale == 1.0 {
                user.setValue("http://paulocustodio.com/wukela/empty.pdf", forKeyPath: "img_srcSync")
            } else if newsJson[count].img_src == nil && scale == 2.0 {
                user.setValue("http://paulocustodio.com/wukela/empty@2x.pdf", forKeyPath: "img_srcSync")
            } else if newsJson[count].img_src == nil && scale == 3.0 {
                user.setValue("http://paulocustodio.com/wukela/empty@3x.pdf", forKeyPath: "img_srcSync")
            } else {
                user.setValue(newsJson[count].img_src, forKeyPath: "img_srcSync")
            }
            user.setValue(newsJson[count].news_src, forKeyPath: "news_srcSync")
            user.setValue(newsJson[count].cat, forKeyPath: "catSync")
            user.setValue(newsJson[count].epoch, forKeyPath: "epochSync")
            //number each stored coredata element to allow sorting
            user.setValue(count, forKeyPath: "countSync")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    //MARK: - Append NewsSync Coredata to newsCore array
    
    public func appendNews() {
        
        print("appendNews: append coredata to newsCore array")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsSync")
        let sort = NSSortDescriptor(key: "countSync", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {
                
                let headline = data.value(forKey: "headlineSync") as? String ?? "Error 33"
                let url_src = data.value(forKey: "url_srcSync") as! String
                let img_src = data.value(forKey: "img_srcSync") as! String
                let news_src = data.value(forKey: "news_srcSync") as! String
                let cat = data.value(forKey: "catSync") as! String
                let epoch = data.value(forKey: "epochSync") as! Double
                let count = data.value(forKey: "countSync") as! Int

                //create 2d array
                newsCore.append([headline, url_src, img_src, news_src, cat, epoch, count])
                
                //sort count by coredata countSync appended to newsCore array
                //disabled since it causes much delay
                //newsCore = newsCore.sorted(by: {($0[6] as! Int) < ($1[6] as! Int) })
            }
        } catch {
            print("Failed")
        }
    }
    
    
    //MARK: - Check Coredata for active Sources
    
    public func sourceCheck() {
        
        print("sourcecheck: add sources in coredata to activeSources array")
        
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
                        //add sources in coredata to array
                        activeSources.insert(retrievedSource, at: 0)
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    
    //MARK: - Check Coredata for active Topics
    
    public func topicCheck() {
        
        print("topiccheck: add topics in coredata to activeTopics array")
        
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
                        //add topics in coredata to array
                        activeTopics.insert(retrievedTopic, at: 0)
                    } else if retrievedTopic == "Sociedade" {
                        activeTopics.insert("Sociedade e Política", at: 0)
                    } else if retrievedTopic == "Política" {
                        activeTopics.insert("Sociedade e Política", at: 0)
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    
    //MARK: - Filter array generated by Coredata
    
    public func filterNews() {
        
        print("filterNews: filter news sources and topics")
        //appendNews generates newsCore array with coredata
        //filter news_src in newsCore array with active news sources
        //when user toggles news source off he triggers coredata, which is then used to filter newsCore
        //let foundSources = newsCore.filter { $0[3] as! String == activeSources[0] || $0[3] as! String == activeSources[1] || $0[3] as! String == activeSources[2] || $0[3] as! String == activeSources[3] || $0[3] as! String == activeSources[4] || $0[3] as! String == activeSources[5] || $0[3] as! String == activeSources[6] || $0[3] as! String == activeSources[7] || $0[3] as! String == activeSources[8] || $0[3] as! String == activeSources[9] || $0[3] as! String == activeSources[10] || $0[3] as! String == activeSources[11] || $0[3] as! String == activeSources[12] || $0[3] as! String == activeSources[13] || $0[3] as! String == activeSources[14] || $0[3] as! String == activeSources[15] || $0[3] as! String == activeSources[16]}
        let foundSources = newsCore.filter { activeSources.contains($0[3] as! String) }
        
        //mash all the filtered sources
        newsCore = foundSources
        
        //filter news sources based on active topics
        //let foundTopics = newsCore.filter { $0[4] as! String == activeTopics[0] || $0[4] as! String == activeTopics[1] || $0[4] as! String == activeTopics[2] || $0[4] as! String == activeTopics[3] || $0[4] as! String == activeTopics[4] || $0[4] as! String == activeTopics[5] || $0[4] as! String == activeTopics[6]}
        let foundTopics = newsCore.filter { activeTopics.contains($0[4] as! String) }
        
        newsCore = foundTopics
        
    }
}

