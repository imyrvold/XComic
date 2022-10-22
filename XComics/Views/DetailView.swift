//
//  DetailView.swift
//  XComics
//
//  Created by Ivan C Myrvold on 22/10/2022.
//

import SwiftUI

struct DetailView: View {
    let comic: Comic
    @SwiftUI.Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("day: \(comic.day), month: \(comic.month), year: \(comic.year)")
                    .font(.caption)
                VStack(alignment: .leading) {
                    Text("alt:")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text(comic.alt)
                }
                
                VStack(alignment: .leading) {
                    Text("transcript:")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text(comic.transcript)
                }
            }
            .navigationTitle(comic.title)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }, label: {
                        Image(systemName: "arrow.left")
                    })
                }
            }

        .padding(.horizontal)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let comic = Preview.comic(file: "allComics.json").first!

        NavigationStack {
            DetailView(comic: comic)
        }
    }
}
