import Foundation
import UIKit

public class StoryboardUtil: NSObject {
  // Shared singleton instance with board names
  private static let shared = StoryboardUtil()

  private var excludeBoards = ["LaunchScreen"]
  private var boards: Set<String> = []

  private func checkBoardList() {
    if StoryboardUtil.shared.boards.isEmpty {
      let mainBundle = Bundle.main
      let bundlePath = mainBundle.bundlePath
      let filesEnumerator = FileManager.default.enumerator(atPath: bundlePath)!
      while let file = filesEnumerator.nextObject() as? String {
        guard let name = file.getStorybaordName(), !excludeBoards.contains(name) else { continue }
        StoryboardUtil.shared.boards.insert(name)
      }
    }
  }

  // MARK: - Get ViewController From Storyboard

  public func controller<T: UIViewController>(from: T.Type, creator: ((NSCoder) -> UIViewController?)? = nil) -> T {
    checkBoardList()
    let name = String(describing: from)
    for sotyrboardName in StoryboardUtil.shared.boards {
      let storyboard = UIStoryboard(name: sotyrboardName, bundle: nil)
      if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: String], availableIdentifiers[name] != nil {
        if let coder = creator {
          return storyboard.instantiateViewController(identifier: name, creator: coder) as! T
        }
        return storyboard.instantiateViewController(withIdentifier: name) as! T
      }
    }
    fatalError("Error! Board Not Found!")
  }

  // MARK: - Get NavigationController From Storyboard

  public func navigation<T: UINavigationController>(name: String, creator: ((NSCoder) -> UIViewController?)? = nil) -> T {
    checkBoardList()
    for sotyrboardName in StoryboardUtil.shared.boards {
      let storyboard = UIStoryboard(name: sotyrboardName, bundle: nil)
      if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: String], availableIdentifiers[name] != nil {
        if let coder = creator {
          return storyboard.instantiateViewController(identifier: name, creator: coder) as! T
        }
        return storyboard.instantiateViewController(withIdentifier: name) as! T
      }
    }
    fatalError("Error! Board Not Found!")
  }
}

public extension UIWindow {
  // MARK: - Change RootViewController in UIWindow

  func setAnimatedRootViewController(_ newRootViewController: some UIViewController) {
    let previousViewController = rootViewController
    rootViewController = newRootViewController

    UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)

    if let previousViewController {
      previousViewController.dismiss(animated: false) {
        previousViewController.view.removeFromSuperview()
      }
    }
  }
}

public extension UIApplication {
  // NARK: - Find Too ViewController

  class func topViewController(controller: UIViewController = UIApplication.shared.windows.first(where: \.isKeyWindow)!.rootViewController!, complete: @escaping (UIViewController) -> Void) {
    DispatchQueue.main.async {
      if let navigationController = controller as? UINavigationController {
        topViewController(controller: navigationController.visibleViewController!, complete: complete)
        return
      }

      if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
          topViewController(controller: selected, complete: complete)
          return
        }
      }

      if let presented = controller.presentedViewController {
        topViewController(controller: presented, complete: complete)
        return
      }

      complete(controller)
    }
  }

  class func topViewController(complete: @escaping (UIViewController) -> Void) {
    DispatchQueue.main.async {
      guard
        let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow),
        let controller = keyWindow.rootViewController
      else {
        fatalError("Error! Keywindow is nil!. If you use SceneDelegate, can't use this function")
      }

      if let navigationController = controller as? UINavigationController {
        topViewController(controller: navigationController.visibleViewController!, complete: complete)
        return
      }

      if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
          topViewController(controller: selected, complete: complete)
          return
        }
      }
      if let presented = controller.presentedViewController {
        topViewController(controller: presented, complete: complete)
        return
      }
      complete(controller)
    }
  }

  @MainActor
  class func topViewController(controller: UIViewController) async -> UIViewController {
    if let navigationController = controller as? UINavigationController {
      return await topViewController(controller: navigationController.visibleViewController!)
    }

    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return await topViewController(controller: selected)
      }
    }

    if let presented = controller.presentedViewController {
      return await topViewController(controller: presented)
    }

    return controller
  }

  @MainActor
  class func topViewController() async -> UIViewController {
    guard
      let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow),
      let controller = keyWindow.rootViewController
    else {
      fatalError("Error! Keywindow is nil!. If you use SceneDelegate, can't use this function")
    }

    if let navigationController = controller as? UINavigationController {
      return await topViewController(controller: navigationController.visibleViewController!)
    }

    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return await topViewController(controller: selected)
      }
    }

    if let presented = controller.presentedViewController {
      return await topViewController(controller: presented)
    }

    return controller
  }

  // MARK: - Change RootViewController

  class func setRootViewController(viewController: UIViewController) {
    UIApplication.shared.delegate?.window??.setAnimatedRootViewController(viewController)
  }
}

// MARK: - Navigation

public extension UIApplication {
  class func popToTopNavigation() {
    UIApplication.topViewController {
      $0.navigationController?.popViewController(animated: true)
    }
  }

  class func pushToTopNavigation(_ type: (some UIViewController).Type, creator: ((NSCoder) -> UIViewController?)? = nil) {
    UIApplication.topViewController {
      let vc = StoryboardUtil().controller(from: type, creator: creator)
      $0.navigationController?.pushViewController(vc, animated: true)
    }
  }

  class func pushToTopNavigation(_ type: (some UIViewController).Type, creator: ((NSCoder) -> UIViewController?)? = nil) async {
    let topVC = await UIApplication.topViewController()
    let vc = StoryboardUtil().controller(from: type, creator: creator)
    topVC.navigationController?.pushViewController(vc, animated: true)
  }

  class func presentToTop(_ type: (some UIViewController).Type, creator: ((NSCoder) -> UIViewController?)? = nil) {
    UIApplication.topViewController {
      let vc = StoryboardUtil().controller(from: type, creator: creator)
      $0.present(vc, animated: true)
    }
  }

  class func presentToTop(_ type: (some UIViewController).Type, creator: ((NSCoder) -> UIViewController?)? = nil) async {
    let topVC = await UIApplication.topViewController()
    let vc = StoryboardUtil().controller(from: type, creator: creator)
    topVC.present(vc, animated: true)
  }
}

// MARK: - Storyboard name from fileName

extension String {
  func getStorybaordName() -> String? {
    if !self.hasSuffix(".storyboardc") {
      return nil
    }
    let hasSubPath = self.components(separatedBy: "/").count > 1
    if hasSubPath {
      // Check Localized (ex. Base.lproj/Main.storyboardc)
      if self.components(separatedBy: "/").count == 2, self.contains(".lproj/") {
        return self.components(separatedBy: "/").last?.components(separatedBy: ".storyboardc").first
      }
    } else {
      return self.components(separatedBy: ".storyboardc").first
    }
    return nil
  }
}
