import UIKit

class ImageViewerRootView: UIView, RootViewType {
    let transition = MatchTransition()

    weak var imageDatasource: ImageDataSource?
    let imageLoader: ImageLoader
    var initialIndex: Int = 0
    var theme: ImageViewerTheme = .dark
    var options: [ImageViewerOption] = []
    var onIndexChange: ((Int) -> Void)?
    var onDismiss: (() -> Void)?
    var sourceImage: UIImage?
    var hideBlurOverlay: Bool = false
    var hidePageIndicators: Bool = false

    private var pageViewController: UIPageViewController!
    private(set) lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = theme.color
        return view
    }()

    private(set) lazy var navBar: UINavigationBar = {
        let navBar = UINavigationBar(frame: .zero)
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        return navBar
    }()

    private lazy var navItem = UINavigationItem()
    private var onRightNavBarTapped: ((Int) -> Void)?
    private var onRightNavBarSecondaryTapped: ((Int) -> Void)?

    private(set) var currentIndex: Int = 0
    private var initialViewController: ImageViewerController?

    var currentImageView: UIImageView? {
        if let vc = pageViewController?.viewControllers?.first as? ImageViewerController {
            return vc.imageView
        }
        if let vc = initialViewController {
            return vc.imageView
        }
        return nil
    }

    var currentScrollView: UIScrollView? {
        if let vc = pageViewController?.viewControllers?.first as? ImageViewerController {
            return vc.scrollView
        }
        return initialViewController?.scrollView
    }

    var preferredStatusBarStyle: UIStatusBarStyle {
        theme == .dark ? .lightContent : .default
    }

    var prefersStatusBarHidden: Bool { false }
    var prefersHomeIndicatorAutoHidden: Bool { false }

    func willAppear(animated: Bool) {
        navBar.alpha = 0
    }

    func didAppear(animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.navBar.alpha = 1.0
        }
    }

    func willDisappear(animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.navBar.alpha = 0
        }
    }

    func didDisappear(animated: Bool) {
        onDismiss?()
    }

    init(
        imageDataSource: ImageDataSource?,
        imageLoader: ImageLoader,
        options: [ImageViewerOption] = [],
        initialIndex: Int = 0,
        sourceImage: UIImage? = nil
    ) {
        self.imageDatasource = imageDataSource
        self.imageLoader = imageLoader
        self.options = options
        self.initialIndex = initialIndex
        self.currentIndex = initialIndex
        self.sourceImage = sourceImage

        for option in options {
            if case .hidePageIndicators(let hide) = option {
                self.hidePageIndicators = hide
            }
        }

        super.init(frame: .zero)
        setupViews()
        applyOptions()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createViewController(for item: ImageItem, at index: Int) -> UIViewController {
        switch item {
        case .video(let url, let thumbnail):
            return VideoViewerController(index: index, videoURL: url, thumbnail: thumbnail)
        case .image, .url:
            return ImageViewerController(
                index: index,
                imageItem: item,
                imageLoader: imageLoader
            )
        }
    }

    private func getIndex(from viewController: UIViewController) -> Int? {
        if let imageVC = viewController as? ImageViewerController {
            return imageVC.index
        } else if let videoVC = viewController as? VideoViewerController {
            return videoVC.index
        }
        return nil
    }

    private func setupViews() {
        addSubview(backgroundView)

        let pageOptions = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: pageOptions
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.backgroundColor = .clear

        addSubview(pageViewController.view)

        if let datasource = imageDatasource {
            let imageItem = datasource.imageItem(at: initialIndex)
            let initialVC = createViewController(for: imageItem, at: initialIndex)

            if let imageVC = initialVC as? ImageViewerController {
                self.initialViewController = imageVC
                if let sourceImage = self.sourceImage {
                    imageVC.initialPlaceholder = sourceImage
                }
            }

            initialVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
            pageViewController.setViewControllers([initialVC], direction: .forward, animated: false)

            initialVC.view.setNeedsLayout()
            initialVC.view.layoutIfNeeded()

            onIndexChange?(initialIndex)
        }

        let closeBarButton = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Close button title"),
            style: .plain,
            target: self,
            action: #selector(dismissViewer)
        )
        closeBarButton.tintColor = theme.tintColor
        navItem.rightBarButtonItem = closeBarButton
        navBar.items = [navItem]
        addSubview(navBar)
    }

    private func applyOptions() {
        let closeButton = navItem.rightBarButtonItem
        var rightPrimaryButton: UIBarButtonItem?
        var rightSecondaryButton: UIBarButtonItem?

        func updateRightButtons() {
            var items: [UIBarButtonItem] = []
            if let closeButton = closeButton {
                items.append(closeButton)
            }
            if let rightSecondaryButton = rightSecondaryButton {
                items.append(rightSecondaryButton)
            }
            if let rightPrimaryButton = rightPrimaryButton {
                items.append(rightPrimaryButton)
            }

            navItem.rightBarButtonItems = items.isEmpty ? nil : items
        }
        
        options.forEach { option in
            switch option {
            case .theme(let newTheme):
                self.theme = newTheme
                backgroundView.backgroundColor = newTheme.color
                closeButton?.tintColor = newTheme.tintColor
            case .closeIcon(let icon):
                closeButton?.image = icon
            case .rightNavItemTitle(let title, let onTap):
                let customButton = UIBarButtonItem(
                    title: title,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavItem)
                )
                rightPrimaryButton = customButton
                updateRightButtons()
                onRightNavBarTapped = onTap
            case .rightNavItemIcon(let icon, let onTap):
                let customButton = UIBarButtonItem(
                    image: icon,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavItem)
                )
                rightPrimaryButton = customButton
                updateRightButtons()
                onRightNavBarTapped = onTap
            case .rightNavItemSecondaryIcon(let icon, let destructive, let onTap):
                let customButton = UIBarButtonItem(
                    image: icon,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavItemSecondary)
                )
                if destructive {
                    customButton.tintColor = UIColor.systemRed
                }
                rightSecondaryButton = customButton
                updateRightButtons()
                onRightNavBarSecondaryTapped = onTap
            case .onIndexChange(let callback):
                self.onIndexChange = callback
            case .onDismiss(let callback):
                self.onDismiss = callback
            case .contentMode:
                break
            case .hideBlurOverlay(let hide):
                self.hideBlurOverlay = hide
            case .hidePageIndicators(let hide):
                self.hidePageIndicators = hide
            }
        }
    }

    private func setupGestures() {
        addGestureRecognizer(transition.verticalDismissGestureRecognizer)
        transition.verticalDismissGestureRecognizer.delegate = self

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        pageViewController.view.frame = bounds

        pageViewController.view.setNeedsLayout()
        pageViewController.view.layoutIfNeeded()
        for child in pageViewController.children {
            child.view.setNeedsLayout()
            child.view.layoutIfNeeded()
        }

        let navBarHeight: CGFloat = 44
        let statusBarHeight = safeAreaInsets.top
        let horizontalPadding: CGFloat = 16
        navBar.frame = CGRect(
            x: horizontalPadding,
            y: statusBarHeight,
            width: bounds.width - (horizontalPadding * 2),
            height: navBarHeight
        )
    }

    @objc private func dismissViewer() {
        navigationView?.popView(animated: true)
    }

    @objc private func didSingleTap() {
        let currentAlpha = navBar.alpha
        UIView.animate(withDuration: 0.235) {
            self.navBar.alpha = currentAlpha > 0.5 ? 0.0 : 1.0
        }
    }

    @objc private func didTapRightNavItem() {
        onRightNavBarTapped?(currentIndex)
    }

    @objc private func didTapRightNavItemSecondary() {
        onRightNavBarSecondaryTapped?(currentIndex)
    }

    func setCurrentIndex(_ index: Int) {
        guard let datasource = imageDatasource else { return }
        if index < 0 || index >= datasource.numberOfImages() { return }
        let newVC = createViewController(for: datasource.imageItem(at: index), at: index)
        newVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
        let direction: UIPageViewController.NavigationDirection =
            index >= currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([newVC], direction: direction, animated: true)
        currentIndex = index
        onIndexChange?(currentIndex)
    }
}

extension ImageViewerRootView: TransitionProvider {
    func transitionFor(presenting: Bool, otherView: UIView) -> Transition? {
        return transition
    }
}

extension ImageViewerRootView: MatchTransitionDelegate {
    func matchedViewFor(transition: MatchTransition, otherView: UIView) -> UIView? {
        let imageView = currentImageView
        return imageView
    }

    func matchTransitionWillBegin(transition: MatchTransition) {
        navBar.alpha = 0
        transition.overlayView?.isHidden = hideBlurOverlay
    }
}

extension ImageViewerRootView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scrollView = currentScrollView {
            return scrollView.zoomScale <= scrollView.minimumZoomScale + 0.01
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }
}

extension ImageViewerRootView: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let datasource = imageDatasource,
              let currentIndex = getIndex(from: viewController),
              currentIndex > 0 else {
            return nil
        }

        let newIndex = currentIndex - 1
        let newVC = createViewController(for: datasource.imageItem(at: newIndex), at: newIndex)
        newVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
        return newVC
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let datasource = imageDatasource,
              let currentIndex = getIndex(from: viewController),
              currentIndex < datasource.numberOfImages() - 1 else {
            return nil
        }

        let newIndex = currentIndex + 1
        let newVC = createViewController(for: datasource.imageItem(at: newIndex), at: newIndex)
        newVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
        return newVC
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        guard !hidePageIndicators else { return 0 }
        let count = imageDatasource?.numberOfImages() ?? 0
        return count > 1 ? count : 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
}

extension ImageViewerRootView: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let currentVC = pageViewController.viewControllers?.first,
           let index = getIndex(from: currentVC) {
            currentIndex = index
            onIndexChange?(currentIndex)
        }
    }
}
