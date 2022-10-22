//
//  XComicsApp.swift
//  XComics
//
//  Created by Ivan C Myrvold on 21/10/2022.
//

import SwiftUI

@main
struct XComicsApp: App {
    let comicsViewModel = ComicsViewModel(comics: Preview.comic(file: "allComics.json"))

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: comicsViewModel)
        }
    }
}
