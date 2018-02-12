
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var photoView1: UIView!
    @IBOutlet weak var photoView2: UIView!
    @IBOutlet weak var photoView3: UIView!
    @IBOutlet weak var photoImgView4: UIView!
   
    @IBOutlet weak var numberOfMiles: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var surname: UILabel!
    @IBOutlet weak var age: UILabel!
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var birthDate: UILabel!
    @IBOutlet weak var sex: UILabel!
    
    private let placeholderMarker = RHPlaceholder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundProfileImageContainers()
        
        // Adding placeholder 
        addPlaceholder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fetched data from API simulation
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.removePhaceholder()
        }
    }
    
    private func addPlaceholder() {
        let viewElements: [UIView] = [photoImgView4,
                                      numberOfMiles,
                                      name,
                                      surname,
                                      age,
                                      email,
                                      birthDate,
                                      sex]
        placeholderMarker.register(viewElements)
    }

    @objc private func removePhaceholder() {
        placeholderMarker.remove()
    }
    
    private func roundProfileImageContainers() {
        [photoView1, photoView2, photoView3, photoImgView4].forEach {
            $0.layer.cornerRadius = $0.bounds.width/2
        }
        photoImgView4.layer.masksToBounds = true
    }
}

final class RHPlaceholder {
    
    private var placeholders = [RHPlaceholderItem]()
    private var layerAnimator: RHLayerAnimating
    
    init(layerAnimator: RHLayerAnimating) {
        self.layerAnimator = layerAnimator
    }
    
    convenience init() {
        self.init(layerAnimator: RHLayerAnimatorGradient())
    }
    
    func register(_ viewElements: [UIView]) {
        viewElements.forEach {
            let placeholderItem = RHPlaceholderItem(originItem: $0)
            self.placeholders.append(placeholderItem)
        }
    
        addLayer()
    }
    
    func remove() {
        placeholders.forEach { placeholder in
            let layer = placeholder.shield
            layer.removeFromSuperview()
        }
    }
    
    private func addLayer() {
        placeholders.forEach { placeholder in
            addShieldViewOriginView(from: placeholder)
        }
        
        animate()
    }
    
    private func addShieldViewOriginView(from placeholder: RHPlaceholderItem) {
        let shield = placeholder.shield
        shield.backgroundColor = UIColor.lightGray
        shield.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        
        shield.frame = placeholder.originItem.bounds
        placeholder.originItem.addSubview(shield)
    }
    
    private func animate() {
        placeholders.forEach { [weak self] in
            let layer = $0.shield.layer
            self?.layerAnimator.addAnimation(to: layer)
        }
    }
}

struct RHPlaceholderItem {
    
    let originItem: UIView // TODO [🌶]: consider 'weak'
    let shield = UIView()
    
    init(originItem: UIView) {
        self.originItem = originItem
    }
}

// ------------------------------------------------
// ------------------------------------------------
protocol RHLayerAnimatorGradientConfigurable {
    var animationDuration: CFTimeInterval { get }
    var fromColor: CGColor { get }
    var toColor: CGColor { get }
}

struct RHLayerAnimatorGradientConfiguration: RHLayerAnimatorGradientConfigurable {
    
    private(set) var animationDuration: CFTimeInterval = 0.6
    private(set) var fromColor: CGColor = UIColor.gray.cgColor
    private(set) var toColor: CGColor = UIColor.lightGray.cgColor
}

protocol RHLayerAnimating {
    func addAnimation(to layer: CALayer)
}

struct RHLayerAnimatorGradient: RHLayerAnimating {
    
    struct Constants {
        static let basicAnimationKeyPath = "colors"
        static let gradientAnimationAddKeyPath = "colorChange"
    }
    
    private let configuration: RHLayerAnimatorGradientConfigurable
    
    init(configuration: RHLayerAnimatorGradientConfigurable) {
        self.configuration = configuration
    }
    
    init() {
        self.init(configuration: RHLayerAnimatorGradientConfiguration())
    }
    
    func addAnimation(to layer: CALayer) {
        // A Basic Implementation
        let animation = CABasicAnimation(keyPath: Constants.basicAnimationKeyPath)
        animation.duration = configuration.animationDuration
        animation.toValue = [
            configuration.toColor,
            configuration.fromColor
        ]
        animation.fillMode = kCAFillModeBackwards
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float.greatestFiniteMagnitude
        
        let gradient = CAGradientLayer()
        gradient.frame = layer.bounds
        gradient.colors = [
            configuration.fromColor,
            configuration.toColor
        ]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.add(animation, forKey: Constants.gradientAnimationAddKeyPath)
        
        layer.addSublayer(gradient)
    }
}

// ------------------------------------------------
// ------------------------------------------------

protocol RHLayerAnimatorBlinkConfigurable {
    var animationDuration: CFTimeInterval { get }
    var blinkColor: CGColor { get }
}

struct RHLayerAnimatorBlinkConfiguration: RHLayerAnimatorBlinkConfigurable {

    private(set) var animationDuration: CFTimeInterval = 0.6
    private(set) var blinkColor: CGColor = UIColor.gray.cgColor
}

struct RHLayerAnimatorBlink: RHLayerAnimating {
    
    struct Constants {
        static let basicAnimationKeyPath = "backgroundColor"
        static let gradientAnimationAddKeyPath = "colorChange"
    }
    
    private let configuration: RHLayerAnimatorBlinkConfigurable
    
    init(configuration: RHLayerAnimatorBlinkConfigurable) {
        self.configuration = configuration
    }
    
    func addAnimation(to layer: CALayer) {
        let animation = CABasicAnimation(keyPath: Constants.basicAnimationKeyPath)
        animation.duration = configuration.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.toValue = configuration.blinkColor
        
        layer.add(animation, forKey: Constants.gradientAnimationAddKeyPath)
    }
}