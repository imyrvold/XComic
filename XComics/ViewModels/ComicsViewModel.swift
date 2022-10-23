//
//  ComicsViewModel.swift
//  XComics
//
//  Created by Ivan C Myrvold on 21/10/2022.
//

import SwiftUI
import Combine

final class ComicsViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    @Published var searchText = ""
    @Published var image: Image?
    @Published var disabledLeft = true
    @Published var disabledRight = false
    @Published var selectedNum: Int? = nil {
        didSet {
            guard let url = selectedNum else { return }
            webViewModel.url = "\(explainUrl)/\(url)"
        }
    }
    @Published var loading = false
    
    @Published var comics: [Comic] = []
    @Published var path = NavigationPath()
    @Published var showWebView = false
    lazy var imageLoader = ImageLoader()
    lazy var webViewModel = WebViewModel(url: "\(explainUrl)/600")
    var explainUrl: String {
        "https://www.explainxkcd.com/wiki/index.php"
    }
    var selectedComicInfo: Comic? {
        guard let selectedNum else { return nil }
        return getComic(for: selectedNum)
    }
    
    init() {
        Task {
            await observeSearchText()
        }
    }
    
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

    @MainActor
    func observeSearchText() {
        $searchText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                guard let number = Int(text) else { return }
                self.loading = true
                if let comic = self.getComic(for: number), let url = comic.url {
                    self.selectedNum = comic.num
                    Task {
                        await self.loadImage(at: URLRequest(url: url))
                        self.loading = false
                }
                } else {
                    Task {
                        await self.loadComic(with: number)
                        self.loading = false
                    }
                }
            }
            .store(in: &subscriptions)
    }
    
    func showInfo() {
        guard let selectedNum, let comic = getComic(for: selectedNum) else { return }
        path.append(Destination.info(comic))
    }
    
    @MainActor
    func showExplanation() {
        showWebView = true
    }
    
    @ViewBuilder func viewForDestination(_ destination: Destination) -> some View {
        switch destination {
        case .info(let comic):
            DetailView(comic: comic)
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
            self.selectedNum = nextNum
        } else {
            await loadComic(with: nextNum)
        }
        disabledLeft = self.selectedNum == comics.first?.num
        loading = false
    }
    
    @MainActor
    func loadComic(with num: Int) async {
        do {
            var apiClient = ApiClient<Comic>(method: .GET, path: "\(num)/info.0.json")
            let comic = try await apiClient.getData()
            selectedNum = comic.num
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
}
