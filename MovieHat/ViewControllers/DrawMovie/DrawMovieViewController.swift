import UIKit
import AVFoundation

final class DrawMovieViewController: UIViewController {

    private let animationlength: Double = 2
    private let viewModel: any DrawMovieViewModelProtocol
    private let hatSourceFrame: CGRect
    private let hatImage: UIImage?

    @IBOutlet private(set) weak var dimmingView: UIView!
    @IBOutlet private(set) weak var hatImageView: UIImageView!
    @IBOutlet private weak var posterImageView: RemoteImageView!
    @IBOutlet private weak var tryAgainButton: UIButton!
    @IBOutlet private weak var letsGoButton: UIButton!
    @IBOutlet private weak var buttonStack: UIStackView!
    @IBOutlet private weak var movieTitleLabel: UILabel!
    @IBOutlet private weak var posterCenterYConstraint: NSLayoutConstraint!

    private var drumrollPlayer: AVAudioPlayer?
    private var leftSpotlightLayer: CAGradientLayer?
    private var rightSpotlightLayer: CAGradientLayer?

    init(
        viewModel: any DrawMovieViewModelProtocol,
        hatSourceFrame: CGRect,
        hatImage: UIImage?
    ) {
        self.viewModel = viewModel
        self.hatSourceFrame = hatSourceFrame
        self.hatImage = hatImage
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        posterImageView.clipsToBounds = true
        posterImageView.alpha = 0
        movieTitleLabel.alpha = 0
        buttonStack.alpha = 0

        applyTheme()

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        dimmingView.addGestureRecognizer(tap)

        viewModel.viewDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    func setHatVisible(_ visible: Bool) {
        hatImageView?.alpha = visible ? 1 : 0
    }

    // MARK: - Button Actions

    @IBAction private func didTapTryAgain(_ sender: Any) {
        resetForRedraw { [weak self] in
            self?.viewModel.didTapTryAgain()
        }
    }

    @IBAction private func didTapLetsGo(_ sender: Any) {
        viewModel.didTapLetsGo()
    }

    @objc private func didTapBackground() {
        viewModel.didTapDismiss()
    }

    // MARK: - Animation Sequence

    private func startRevealSequence(for movie: Movie) {
        movieTitleLabel.text = movie.title
        if let posterURL = movie.posterURL {
            posterImageView.load(from: posterURL)
        }
        resetPosterPosition()
        startDrumroll()
    }

    private func startDrumroll() {
        animateSpotlights()

        if let url = Bundle.main.url(forResource: "drumroll-trimmed", withExtension: "mp3") {
            do {
                drumrollPlayer = try AVAudioPlayer(contentsOf: url)
                drumrollPlayer?.play()
            } catch {}
        }

        // Trigger the continuation of the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationlength) { [weak self] in
            self?.drumrollDidFinish()
        }
    }

    private func drumrollDidFinish() {
        animatePosterReveal()
        removeSpotlights()
    }

    // MARK: - Poster Animation

    private func animatePosterReveal() {
        posterCenterYConstraint.constant = -130

        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.posterImageView.alpha = 1
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.animateTitleAndButtonsIn()
            }
        )
    }

    private func resetPosterPosition() {
        posterCenterYConstraint.constant = 300
        posterImageView.alpha = 0
        view.layoutIfNeeded()
    }

    private func animateTitleAndButtonsIn() {
        UIView.animate(withDuration: 0.3) {
            self.movieTitleLabel.alpha = 1
            self.buttonStack.alpha = 1
        }
    }

    private func resetForRedraw(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.posterImageView.alpha = 0
                self.movieTitleLabel.alpha = 0
                self.buttonStack.alpha = 0
            },
            completion: { _ in
                self.resetPosterPosition()
                completion()
            }
        )
    }

    // MARK: - Spotlight Animation

    private func animateSpotlights() {
        let screenBounds = view.bounds

        let offscreenY: CGFloat = -100

        let leftLayer = makeSpotlightLayer(bounds: screenBounds)
        leftLayer.anchorPoint = CGPoint(x: 0, y: 0)
        leftLayer.position = CGPoint(x: 0, y: offscreenY)
        leftLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 6, 0, 0, 1)
        view.layer.addSublayer(leftLayer)
        leftSpotlightLayer = leftLayer

        let rightLayer = makeSpotlightLayer(bounds: screenBounds)
        rightLayer.anchorPoint = CGPoint(x: 1, y: 0)
        rightLayer.position = CGPoint(x: screenBounds.width, y: offscreenY)
        rightLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 6, 0, 0, 1)
        view.layer.addSublayer(rightLayer)
        rightSpotlightLayer = rightLayer

        // Sweep animations
        let leftSweep = CABasicAnimation(keyPath: "transform.rotation.z")
        leftSweep.fromValue = -CGFloat.pi / 6
        leftSweep.toValue = CGFloat.pi / 8
        leftSweep.duration = animationlength
        leftSweep.fillMode = .forwards
        leftSweep.isRemovedOnCompletion = false
        leftLayer.add(leftSweep, forKey: "sweep")

        let rightSweep = CABasicAnimation(keyPath: "transform.rotation.z")
        rightSweep.fromValue = CGFloat.pi / 6
        rightSweep.toValue = -CGFloat.pi / 8
        rightSweep.duration = animationlength
        rightSweep.fillMode = .forwards
        rightSweep.isRemovedOnCompletion = false
        rightLayer.add(rightSweep, forKey: "sweep")

        // Strobe pulse
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 0.3
        pulse.toValue = 0.6
        pulse.duration = 0.15
        pulse.autoreverses = true
        pulse.repeatCount = 13
        leftLayer.add(pulse, forKey: "strobe")
        rightLayer.add(pulse, forKey: "strobe")
    }

    private func applyTheme() {
        dimmingView.backgroundColor = Theme.dimmingOverlay
        posterImageView.backgroundColor = Theme.drawMoviePosterPlaceholder
        movieTitleLabel.textColor = Theme.invertedText
        tryAgainButton.backgroundColor = Theme.secondaryButton
        tryAgainButton.setTitleColor(.black, for: .normal)
        letsGoButton.backgroundColor = Theme.primaryButton
        letsGoButton.setTitleColor(Theme.invertedText, for: .normal)
    }

    private func makeSpotlightLayer(bounds: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.type = .radial
        layer.colors = [
            Theme.spotlight.withAlphaComponent(0.5).cgColor,
            Theme.spotlight.withAlphaComponent(0.0).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.frame = CGRect(x: 0, y: 0, width: 120, height: bounds.height)
        layer.opacity = 0.5
        return layer
    }

    private func removeSpotlights() {
        leftSpotlightLayer?.removeAllAnimations()
        leftSpotlightLayer?.removeFromSuperlayer()
        leftSpotlightLayer = nil

        rightSpotlightLayer?.removeAllAnimations()
        rightSpotlightLayer?.removeFromSuperlayer()
        rightSpotlightLayer = nil
    }
}

// MARK: - DrawMovieViewModelViewDelegate

extension DrawMovieViewController: DrawMovieViewModelViewDelegate {
    func bind(viewModel: any DrawMovieViewModelProtocol) {
        guard let movie = viewModel.drawnMovie else { return }
        startRevealSequence(for: movie)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension DrawMovieViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        DrawMoviePresentationAnimator(
            hatSourceFrame: hatSourceFrame,
            hatImage: hatImage
        )
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        DrawMovieDismissalAnimator()
    }
}
