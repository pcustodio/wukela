//
//  NewsData.swift
//  wukela
//
//  Created by Paulo Custódio on 26/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import Foundation

//our data structure
struct NewsData : Codable {
    var headline: String?
    var img_src: String?
    var url_src: String?
    var news_src: String?
    var cat: String?
    var lang: String?
    var epoch: Double
}
