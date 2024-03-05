import UIKit

class CircularProgessButton: UIView {
    
    // MARK: - Variables
    private let circleLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    private let startPoint = CGFloat(-Double.pi / 2)
    private let endPoint = CGFloat(3 * Double.pi / 2)
    private let circularViewDuration: TimeInterval = 0
    private let lineWidth = 10.0;
    private var circularPathRadius : CGFloat   {
        return (frame.size.width - lineWidth ) / 2.0
    };
    private let strokeEndObserverKeyPath = "presentation.strokeEnd"
    private let strokeEndKeyPath = "strokeEnd"
    private let strokeEndAnimationKeyPath = "strokeEndAnimation"
    
    // MARK: - UI Components
    let defaultIcon: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right")
        image.tintColor = .systemBackground
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        createCircularPath()
        setupDefaultIcon()
    }
    
    private func setupDefaultIcon(){
        self.addSubview(defaultIcon)
        defaultIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            defaultIcon.widthAnchor.constraint(equalToConstant: 10),
            defaultIcon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            defaultIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
        ])
        
    }
    private func createCircularPath() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: circularPathRadius, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        
        self.circleLayer.path = circularPath.cgPath
        self.circleLayer.fillColor = UIColor.label.cgColor
        self.circleLayer.lineCap = .round
        self.circleLayer.lineWidth = lineWidth
        self.circleLayer.strokeEnd = 1
        self.circleLayer.strokeColor = UIColor.systemBackground.cgColor
        self.layer.addSublayer(circleLayer)
        
        
        self.maskLayer.path = circularPath.cgPath
        self.maskLayer.fillColor = UIColor.clear.cgColor
        self.maskLayer.lineCap = .round
        self.maskLayer.lineWidth = 3
        self.maskLayer.strokeEnd = 1
        self.maskLayer.strokeColor = UIColor.label.withAlphaComponent(0.5).cgColor
        self.layer.addSublayer(maskLayer)
        
        self.progressLayer.path = circularPath.cgPath
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.lineCap = .round
        self.progressLayer.lineWidth = 3
        self.progressLayer.strokeEnd = 0
        self.progressLayer.strokeColor = UIColor.label.cgColor
        self.layer.addSublayer(progressLayer)
        
        
    }
    
    func progressAnimation(to percentage: Double) {
        progressLayer.strokeEnd = percentage / 100
    }
}
