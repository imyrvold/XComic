//
//  ContentView.swift
//  XComics
//
//  Created by Ivan C Myrvold on 21/10/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ComicsViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("")
                    .searchable(text: $viewModel.searchText)
                HStack {
                    Button(action: {
                        Task {
                            await viewModel.previous()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                    }
                    .disabled(viewModel.disabledLeft)
                    Spacer()
                    if viewModel.loading {
                        ProgressView()
                    }
                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.next()
                        }
                    }) {
                        Image(systemName: "arrow.right")
                    }
                    .disabled(viewModel.disabledRight)
                }
                .font(.title)
                .padding(.bottom)
                viewModel.selectedComic
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("XComics")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let comics = Preview.comic(file: "allComics.json")
        let viewModel = ComicsViewModel(comics: comics)
//        ContentView()
        ContentView(viewModel: viewModel)
    }
}
