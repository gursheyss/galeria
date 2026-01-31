import UIKit

public enum ImageItem {
    case image(UIImage?)
    case url(URL, placeholder: UIImage?)
    case video(URL, thumbnail: UIImage?)

    var isVideo: Bool {
        if case .video = self { return true }
        return false
    }
}
