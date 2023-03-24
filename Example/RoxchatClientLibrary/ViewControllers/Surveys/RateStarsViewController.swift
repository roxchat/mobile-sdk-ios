
import AVFoundation
import Cosmos
import UIKit

protocol RateStarsViewControllerDelegate: AnyObject {
    
    func rateOperator(operatorID: String, rating: Int)
}

class RateStarsViewController: WMSurveyViewController {
    
    // MARK: - Init Properties
    weak var rateOperatorDelegate: RateStarsViewControllerDelegate?
    var operatorId = String()
    var operatorRating = 0.0
    var isSurvey = false
    var descriptionText: String?

    // MARK: - IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    // MARK: - Subviews
    private var cosmosRatingView: CosmosView = RateStarsViewController.configureCosmosView()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    private func setupSubviews() {
        
        if self.isSurvey {
            self.titleLabel.alpha = 0
        }
        descriptionLabel.text = isSurvey ? descriptionText : "Please rate the overall impression of the consultation".localized
        
        self.disableSendButton()
        
        cosmosRatingView.rating = operatorRating
        
        self.cosmosRatingView.didFinishTouchingCosmos = { (rating) -> Void in
            self.operatorRating = rating
            self.enableSendButton()
        }
        containerView.addSubview(cosmosRatingView)

    }

    @IBAction func sendRate(_ sender: Any) {
        let rating = Int(operatorRating)
        
        if isSurvey {
            self.delegate?.sendSurveyAnswer("\(rating)")
        } else {
            self.rateOperatorDelegate?.rateOperator(operatorID: self.operatorId, rating: rating)
        }
        
        self.close(nil)
    }
    
    private static func configureCosmosView() -> CosmosView {
        let cosmosView = CosmosView()
        cosmosView.translatesAutoresizingMaskIntoConstraints = false
        cosmosView.settings.fillMode = .full
        cosmosView.settings.starSize = 30
        cosmosView.settings.filledColor = cosmosViewFilledColour
        cosmosView.settings.filledBorderColor = cosmosViewFilledBorderColour
        cosmosView.settings.emptyColor = cosmosViewEmptyColour
        cosmosView.settings.emptyBorderColor = cosmosViewEmptyBorderColour
        cosmosView.settings.emptyBorderWidth = 2
        
        return cosmosView
    }
}
