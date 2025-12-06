//
//  ImageCache.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import UIKit
import Combine

protocol ImageCaching {
    subscript(_ url: URL) -> UIImage? { get set }
}

final class ImageCache: ImageCaching {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    subscript(_ url: URL) -> UIImage? {
        get { cache.object(forKey: url as NSURL) }
        set {
            if let image = newValue {
                cache.setObject(image, forKey: url as NSURL)
            } else {
                cache.removeObject(forKey: url as NSURL)
            }
        }
    }
}

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var cancellable: AnyCancellable?

    func load(from url: URL) {
        if let cached = ImageCache.shared[url] {
            self.image = cached
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { UIImage(data: $0) }
            .handleEvents(receiveOutput: { ImageCache.shared[url] = $0 })
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .assign(to: \.image, on: self)
    }

    func cancel() {
        cancellable?.cancel()
    }
}

