
import UIKit

class SurveyTableViewCell: UITableViewCell {

    @IBOutlet var pointSelectionImageView: UIImageView!
    @IBOutlet var pointTitle: UILabel!
    
    func setSelected(_ selected: Bool) {
        if selected {
            self.pointSelectionImageView.image = selectedSurveyPoint
        } else {
            self.pointSelectionImageView.image = unselectedSurveyPoint
        }
    }
}
