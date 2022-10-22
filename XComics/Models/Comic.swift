//
//  Comic.swift
//  XComics
//
//  Created by Ivan C Myrvold on 21/10/2022.
//

import Foundation

struct Comic: Identifiable, Hashable, Decodable {
    var id: Int {
        num
    }
    
    var url: URL? {
        URL(string: img)
    }
    
    let month: String
    let num: Int
    let link: String
    let news: String
    let safeTitle: String
    let transcript: String
    let alt: String
    let img: String
    let title: String
    let day: String
    let year: String
    
    private enum CodingKeys: String, CodingKey {
        case month
        case num
        case link
        case news
        case safeTitle = "safe_title"
        case transcript
        case alt
        case img
        case title
        case day
        case year
    }
}
