import ExpoModulesCore

public class GaleriaModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Galeria")

    View(GaleriaView.self) {
      Events(
        "onIndexChange",
        "onPressRightNavItemIcon",
        "onPressRightNavItemSecondaryIcon"
      )

      OnViewDidUpdateProps { (view) in
        view.setupImageView()
      }

      Prop("urls") { (view, urls: [String]?) in
        view.urls = urls
      }

      Prop("mediaTypes") { (view, mediaTypes: [String]?) in
        view.mediaTypes = mediaTypes
      }

      Prop("index") { (view, index: Int?) in
        view.initialIndex = index
      }

      Prop("theme") { (view, theme: Theme?) in
        view.theme = theme ?? .dark
      }
      Prop("closeIconName") { (view, closeIconName: String?) in
        view.closeIconName = closeIconName
      }
      Prop("rightNavItemIconName") { (view, rightNavItemIconName: String?) in
        view.rightNavItemIconName = rightNavItemIconName
      }

      Prop("rightNavItemSecondaryIconName") { (view, rightNavItemSecondaryIconName: String?) in
        view.rightNavItemSecondaryIconName = rightNavItemSecondaryIconName
      }

      Prop("rightNavItemSecondaryDestructive") { (view, rightNavItemSecondaryDestructive: Bool?) in
        view.rightNavItemSecondaryDestructive = rightNavItemSecondaryDestructive ?? false
      }

      Prop("hideBlurOverlay") { (view, hideBlurOverlay: Bool?) in
        view.hideBlurOverlay = hideBlurOverlay ?? false
      }

      Prop("hidePageIndicators") { (view, hidePageIndicators: Bool?) in
        view.hidePageIndicators = hidePageIndicators ?? false
      }

    }

    Function("close") {
      print("[galeria] close() called")
      DispatchQueue.main.async {
        galeriaCloseCurrentViewer()
      }
    }
  }

  func onIndexChange(index: Int) {
    sendEvent("onIndexChange", ["currentIndex": index])
  }
}
