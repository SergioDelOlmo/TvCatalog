//
//  Models.swift
//  TvCatalogTest
//
//  Created by Sergio Del Olmo Aguilar on 29/11/22.
//

import Foundation

protocol TableViewCellProtocol {
    func getImageUrl() -> String?
    func getShowName() -> String?
}

class TvShow:Codable {
    var id:Int?
    var summary:String?
    var show:Show?
    var isFavourite:Bool?
}

class Show:Codable {
    var name:String?
    var type:String?
    var schedule:Schedule?
    var externals:Externals?
    var image:Image?
}

class Schedule:Codable {
    var time:String?
    var days:[String]?
}

class Externals:Codable {
    var tvrage:Int?
    var thetvdb:Int?
    var imdb:String?
}

class Image:Codable {
    var medium:String?
    var original:String?
    
    init(medium: String? = nil, original: String? = nil) {
        self.medium = medium
        self.original = original
    }
}

extension TvShow:TableViewCellProtocol {
    func getImageUrl() -> String? {
        if let imageUrl = self.show?.image?.medium {
            return imageUrl
        } else {
            return String()
        }
    }
    func getShowName() -> String? {
        if let showName = self.show?.name {
            return showName
        } else {
            return String()
        }
    }
}

