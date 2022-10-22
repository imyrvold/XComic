//
//  ComicsViewModel.swift
//  XComics
//
//  Created by Ivan C Myrvold on 21/10/2022.
//

import SwiftUI

final class ComicsViewModel: ObservableObject {
    @Published var num = 600
    @Published var searchText = ""
    @Published var image: Image?
    @Published var disabledLeft = true
    @Published var disabledRight = false
    @Published var selectedNum: Int? = nil
    @Published var loading = false
    
    @Published var comics: [Comic] = []
    lazy var imageLoader = ImageLoader()
    
    init() {}
    
    convenience init(comics: [Comic]) {
        self.init()
        self.comics = comics
        if let url = comics.first?.url {
            Task {
                await loadImage(at: URLRequest(url: url))
                selectedNum = comics.first?.num
            }
        }
    }
    
    @MainActor
    func loadImage(at source: URLRequest) async {
        do {
            let image = try await imageLoader.fetch(source)
            self.image = Image(uiImage: image)
        } catch {
            print(error)
        }
    }
    
    @ViewBuilder var selectedComic: some View {
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Text("Loading comics...")
                .font(.title)
        }
    }
    
    @MainActor
    func previous() async {
        guard let selectedNum else { return }
        loading = true
        let previousNum = max(selectedNum - 1, 0)
        if let comic = comics.first(where: { $0.num == previousNum }), let url = comic.url {
            await loadImage(at: URLRequest(url: url))
            self.selectedNum = previousNum
        }
        disabledLeft = self.selectedNum == comics.first?.num
        disabledRight = self.selectedNum == comics.last?.num
        loading = false
    }
    
    @MainActor
    func next() async {
        guard let selectedNum, let lastNum = comics.last?.num else { return }
        loading = true
        let nextNum = min(selectedNum + 1, lastNum)
        if let comic = comics.first(where: { $0.num == nextNum }), let url = comic.url {
            await loadImage(at: URLRequest(url: url))
            self.selectedNum = nextNum
        } else {
            do {
                var apiClient = ApiClient<Comic>(method: .GET, path: "\(selectedNum)/info.0.json")
                let comic = try await apiClient.getData()
                comics.append(comic)
            } catch {
                
            }
        }
        disabledLeft = self.selectedNum == comics.first?.num
        disabledRight = self.selectedNum == comics.last?.num
        loading = false
    }
}
