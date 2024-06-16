import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func showAnimation() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismissAnimation() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    static func block() {
        window?.isUserInteractionEnabled = false
    }
    
    static func unblock() {
        window?.isUserInteractionEnabled = true
    }
}
