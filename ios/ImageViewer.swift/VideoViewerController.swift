import UIKit
import AVKit

class VideoViewerController: UIViewController {

    var index: Int = 0
    var videoURL: URL!
    var thumbnailImage: UIImage?

    private var playerViewController: AVPlayerViewController!
    private var player: AVPlayer!
    private var thumbnailView: UIImageView?

    init(index: Int, videoURL: URL, thumbnail: UIImage? = nil) {
        self.index = index
        self.videoURL = videoURL
        self.thumbnailImage = thumbnail
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupPlayer()
    }

    private func setupPlayer() {
        player = AVPlayer(url: videoURL)

        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        playerViewController.videoGravity = .resizeAspect
        playerViewController.view.backgroundColor = .clear

        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        playerViewController.didMove(toParent: self)

        // Add thumbnail overlay initially
        if let thumbnail = thumbnailImage {
            let imageView = UIImageView(image: thumbnail)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            self.thumbnailView = imageView
        }

        // Hide thumbnail when video starts playing
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidStartPlaying),
            name: .AVPlayerItemNewAccessLogEntry,
            object: player.currentItem
        )
    }

    @objc private func playerDidStartPlaying() {
        UIView.animate(withDuration: 0.3) {
            self.thumbnailView?.alpha = 0
        } completion: { _ in
            self.thumbnailView?.removeFromSuperview()
            self.thumbnailView = nil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Auto-play when view appears
        player.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        player = nil
    }
}
