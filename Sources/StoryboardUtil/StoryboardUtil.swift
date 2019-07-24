import UIKit

public class StoryboardUtil: NSObject {
    
    public static let shared = StoryboardUtil()
    
    public var boards = [String]()
    
    // MARK: Get ViewController From Storyboard
    
    public func controller<T: UIViewController>(from: T.Type) -> T {
        
        let name = String(describing: from)
        
        for sotyrboardName in StoryboardUtil.shared.boards {
            
            let storyboard = UIStoryboard(name: sotyrboardName, bundle: nil)
            
            if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any], availableIdentifiers[name] != nil {
                return storyboard.instantiateViewController(withIdentifier: name) as! T
            }
        }
        
        assertionFailure("Error! Board Not Found!")
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! T
    }
    
    // MARK: Get NavigationController From Storyboard
    
    public func navigation<T: UINavigationController>(name: String) -> T {
        
        for sotyrboardName in StoryboardUtil.shared.boards {
            
            let storyboard = UIStoryboard(name: sotyrboardName, bundle: nil)
            
            if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any], availableIdentifiers[name] != nil {
                return storyboard.instantiateViewController(withIdentifier: name) as! T
            }
        }
        
        assertionFailure("Error! Board Not Found!")
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! T
    }
    
    // MARK: Get Default NavigationController From ViewController
    
    public func defaultNavigation<T: UIViewController>(root: T, isClear: Bool = false, isUseTheme: Bool = true) -> UINavigationController {
        
        root.title = nil
        
        let naviController = UINavigationController(rootViewController: root)
        naviController.navigationBar.isTranslucent = false
        
        return naviController
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
        
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}

extension UIApplication {
    
    // NARK: Find Too ViewController
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController, complete: @escaping (UIViewController?) -> Void) {
        
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
    
    class func topViewController(complete: @escaping (UIViewController?) -> Void) {
        
        DispatchQueue.main.async {
            
            let controller = UIApplication.shared.keyWindow?.rootViewController
            
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
    
    // MARK: Change RootViewController
    
    class func setRootViewController(viewController: UIViewController) {
        
        UIApplication.shared.delegate?.window??.setAnimatedRootViewController(viewController)
    }
}
