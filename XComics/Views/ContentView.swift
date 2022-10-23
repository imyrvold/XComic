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
        NavigationStack(path: $viewModel.path) {
            VStack {
                Text("")
                    .searchable(text: $viewModel.searchText, prompt: "Search for number")
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
                    } else {
                        HStack {
                            if let comic = viewModel.selectedComicInfo {
                                Text(comic.title)
                                    .font(.title2)
                            }
                            Button(action: { viewModel.showInfo() }) {
                                Image(systemName: "info.circle")
                                    .font(.title)
                            }
                        }
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
                .navigationDestination(for: ComicsViewModel.Destination.self) { destination in
                    viewModel.viewForDestination(destination)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewModel.showExplanation() }, label: {
                            Image(systemName: "questionmark.app")
                        })
                    }
                }
                .fullScreenCover(isPresented: $viewModel.showWebView) {
                    NavigationStack {
                        WebViewContainer(webViewModel: viewModel.webViewModel)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: { viewModel.showWebView = false }, label: {
                                        Image(systemName: "xmark")
                                    })
                                }
                            }
                    }
                }

                viewModel.selectedComic
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("XComics")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let comics = Preview.comic(file: "allComics.json")
        let viewModel = ComicsViewModel(comics: comics)
        ContentView(viewModel: viewModel)
    }
}
