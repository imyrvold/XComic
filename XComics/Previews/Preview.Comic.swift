//
//  Preview.Comic.swift
//  XComics
//
//  Created by Ivan C Myrvold on 21/10/2022.
//

import Foundation

enum Preview {
    static func comic(file: String) -> [Comic] {
        Bundle.main.decode([Comic].self, from: file)
    }
}
