//
//  NewsLoader.swift
//  wukela
//
//  Created by Paulo Custódio on 26/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import Foundation

//load data from json and turn it into my data structure on Dictionary.swift
public class NewsLoader {
    
    //store all the data that is retrieved from json file
    var news = [NewsData]()
    
    //run our load & sort functions when our class DictionaryLoader is created
    init() {
        load()
        //sort()
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
                self.news = dataFromJson.reversed()
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


    
}

