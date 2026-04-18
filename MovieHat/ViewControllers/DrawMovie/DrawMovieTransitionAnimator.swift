import UIKit

final class DrawMoviePresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let hatSourceFrame: CGRect
    private let hatImage: UIImage?

    init(
        hatSourceFrame: CGRect,
        hatImage: UIImage?
    ) {
        self.hatSourceFrame = hatSourceFrame
        self.hatImage = hatImage
    }

    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        1.0
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
              let toVC = transitionContext.viewController(forKey: .to) as? DrawMovieViewController,
              let fromVC = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        // Hide the original hat on the home screen so the snapshot looks like the real hat moving
        let homeVC = (fromVC as? UINavigationController)?.topViewController as? HomeViewController
        homeVC?.setHatVisible(false)

        // Set up destination view with dimming at alpha 0 and hat hidden
        toView.frame = finalFrame
        toView.alpha = 0
        toVC.setHatVisible(false)
        container.addSubview(toView)

        // Create snapshot of the hat at its source position
        let snapshotHat = UIImageView(image: hatImage)
        snapshotHat.contentMode = .scaleAspectFit
        snapshotHat.frame = hatSourceFrame
        container.addSubview(snapshotHat)

        // Calculate destination frame: edge-to-edge, bottom 1/3 off-screen
        let screenBounds = container.bounds
        let hatAspect: CGFloat = 593.0 / 773.0
        let destWidth = screenBounds.width
        let destHeight = destWidth * hatAspect
        let destY = screenBounds.height - destHeight + 50
        let destinationFrame = CGRect(x: 0, y: destY, width: destWidth, height: destHeight)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            snapshotHat.frame = destinationFrame
            toView.alpha = 1
        } completion: { _ in
            toVC.setHatVisible(true)
            snapshotHat.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

final class DrawMovieDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.35
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        // Restore the hat on the home screen before fading out
        if let toVC = transitionContext.viewController(forKey: .to) {
            let homeVC = (toVC as? UINavigationController)?.topViewController as? HomeViewController
            homeVC?.setHatVisible(true)
        }

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromView.alpha = 0
            },
            completion: { _ in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
