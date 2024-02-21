import Foundation
import UIKit

public class StoryboardUtil: NSObject {
    
    public var boards: [String] {
        if let path = Bundle.main.path(forResource: "StoryboardList", ofType: "txt"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            let storybaordList = content.components(separatedBy: "\n").filter { !$0.isEmpty }
            return storybaordList.map { $0.replacingOccurrences(of: ".storyboard", with: "") }
        }
        return []
    }

    // MARK: Get ViewController From Storyboard
    
    public func controller<T: UIViewController>(from: T.Type, creator: ((NSCoder) -> UIViewController?)? = nil) -> T {
        let name = String(describing: from)
        for sotyrboardName in boards {
            let storyboard = UIStoryboard(name: sotyrboardName, bundle: nil)
            if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any], availableIdentifiers[name] != nil {
                if let coder = creator {
                    return storyboard.instantiateViewController(identifier: name, creator: coder) as! T
                }
                return storyboard.instantiateViewController(withIdentifier: name) as! T
            }
        }
        assertionFailure("Error! Board Not Found!")
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! T
    }

    // MARK: Get NavigationController From Storyboard
    
    public func navigation<T: UINavigationController>(name: String, creator: ((NSCoder) -> UIViewController?)? = nil) -> T {
        for sotyrboardName in boards {
            let storyboard = UIStoryboard(name: sotyrboardName, bundle: nil)
            if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any], availableIdentifiers[name] != nil {
                if let coder = creator {
                    return storyboard.instantiateViewController(identifier: name, creator: coder) as! T
                }
                return storyboard.instantiateViewController(withIdentifier: name) as! T
            }
        }
        assertionFailure("Error! Board Not Found!")
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! T
    }
}

extension UIWindow {
    
    // MARK: Change RootViewController in UIWindow
    
    public func setAnimatedRootViewController<T: UIViewController>(_ newRootViewController: T) {
        let previousViewController = rootViewController
        rootViewController = newRootViewController
        
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        
        if let previousViewController = previousViewController {
            previousViewController.dismiss(animated: false) {
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}

extension UIApplication {
    
    // NARK: Find Too ViewController
    
    public class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController, complete: @escaping (UIViewController?) -> Void) {

        DispatchQueue.main.async {

            if let navigationController = controller as? UINavigationController {
                topViewController(controller: navigationController.visibleViewController, complete: complete)
                return
            }

            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    topViewController(controller: selected, complete: complete)
                    return
                }
            }

            if let presented = controller?.presentedViewController {
                topViewController(controller: presented, complete: complete)
                return
            }

            complete(controller)
        }
    }
    
    public class func topViewController(complete: @escaping (UIViewController?) -> Void) {
        
        DispatchQueue.main.async {
            
            let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow)
            let controller = keyWindow?.rootViewController
            
            if let navigationController = controller as? UINavigationController {
                topViewController(controller: navigationController.visibleViewController, complete: complete)
                return
            }
            
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    topViewController(controller: selected, complete: complete)
                    return
                }
            }
            
            if let presented = controller?.presentedViewController {
                topViewController(controller: presented, complete: complete)
                return
            }
            
            complete(controller)
        }
    }
    
    @MainActor
    public class func topViewController(controller: UIViewController?) async -> UIViewController? {

        if let navigationController = controller as? UINavigationController {
            return await topViewController(controller: navigationController.visibleViewController)
        }

        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return await topViewController(controller: selected)
            }
        }

        if let presented = controller?.presentedViewController {
            return await topViewController(controller: presented)
        }
        
        return controller
    }
    
    @MainActor
    public class func topViewController() async -> UIViewController? {
        
        let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow)
        let controller = keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return await topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return await topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return await topViewController(controller: presented)
        }
        
        return controller
    }
    
    // MARK: Change RootViewController
    
    public class func setRootViewController(viewController: UIViewController) {
        UIApplication.shared.delegate?.window??.setAnimatedRootViewController(viewController)
    }
}
