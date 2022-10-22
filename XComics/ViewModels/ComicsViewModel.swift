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
    @Published var path = NavigationPath()
    lazy var imageLoader = ImageLoader()
    
    init() {}
    
    convenience init(comics: [Comic]) {
        self.init()
        self.comics = comics
        if let url = comics.first?.url {
            Task {
                await loadImage(at: URLRequest(url: url))
                DispatchQueue.main.async {
                    self.selectedNum = comics.first?.num
                }
            }
        }
    }
    
    enum Destination: Hashable {
        case info(Comic)
    }
    
    func showInfo() {
        guard let selectedNum, let comic = getComic(for: selectedNum) else { return }
        path.append(Destination.info(comic))
    }
    
    @ViewBuilder func viewForDestination(_ destination: Destination) -> some View {
        switch destination {
        case .info(let comic):
            Text("Hullu title: \(comic.title)")
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
        if let comic = getComic(for: previousNum), let url = comic.url {
            await loadImage(at: URLRequest(url: url))
            self.selectedNum = previousNum
        }
        disabledLeft = self.selectedNum == comics.first?.num
        loading = false
    }
    
    func getComic(for num: Int) -> Comic? {
        comics.first(where: { $0.num == num })
    }
    
    @MainActor
    func next() async {
        guard let selectedNum else { return }
        loading = true
        let nextNum = selectedNum + 1
        if let comic = comics.first(where: { $0.num == nextNum }), let url = comic.url {
            await loadImage(at: URLRequest(url: url))
        } else {
            do {
                var apiClient = ApiClient<Comic>(method: .GET, path: "\(nextNum)/info.0.json")
                let comic = try await apiClient.getData()
                comics.append(comic)
                if let url = comic.url {
                    await loadImage(at: URLRequest(url: url))
                }
            } catch {
                if let error = error as? AppError {
                    print("Error loading next comic:", error.localizedDescription)
                } else {
                    print("Error loading next comic:", error.localizedDescription)
                }
            }
        }
        self.selectedNum = nextNum
        disabledLeft = self.selectedNum == comics.first?.num
        loading = false
    }
}
