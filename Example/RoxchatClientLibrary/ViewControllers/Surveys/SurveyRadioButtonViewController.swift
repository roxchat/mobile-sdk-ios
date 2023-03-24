
import AVFoundation
import UIKit

class SurveyRadioButtonViewController: WMSurveyViewController, WMFixedWidthViewDelegate {

    var descriptionText: String?
    var points: [String] = []
    var selectedPoint = -1
    
    var savedHeaderHeight: CGFloat = 0
    @IBOutlet var tableHeaderView: WMFixedWidthView!
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var grayViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButtonView: UIView!
    
    private var cells = [SurveyTableViewCell]()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = descriptionText
        descriptionLabel.setNeedsLayout()
        
        self.tableHeaderView.delegate = self
        
        for text in points {
            let cell = tableView.dequeueReusableCellWithType(SurveyTableViewCell.self)
            cell.pointTitle.text = text
            self.cells.append(cell)
        }
        
        self.disableSendButton()
        self.tableView.reloadData()
        self.view.setNeedsLayout()
        recountContentViewHeight()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc
    func rotated() {
        recountContentViewHeight()
    }
    
    @IBAction private func send(_ sender: Any) {
        // important: radio button answer numeration starts from 1
        self.delegate?.sendSurveyAnswer("\(selectedPoint + 1)")
        self.closeViewController()
    }
    
    func viewWillResize(_ view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.tableView.reloadData()
            self.recountContentViewHeight()
        }
    }
    
    func recountContentViewHeight() {
        let contentViewHeight = self.tableView.contentSize.height + self.sendButtonView.frame.height + self.tableHeaderView.frame.height
        
        var greyViewHeight = max(WMInterfaceData.shared.screenHeight() - contentViewHeight, 0)
        if greyViewHeight < 100 {
            if WMInterfaceData.shared.screenHeight() < 450 {
                greyViewHeight = 0
            } else {
                greyViewHeight = 100
            }
        }
        self.grayViewHeightConstraint.constant = greyViewHeight
    }
}

extension SurveyRadioButtonViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.savedHeaderHeight != self.tableHeaderView.frame.height {
            self.savedHeaderHeight = self.tableHeaderView.frame.height
            self.tableView.reloadData()
        }

        return self.tableHeaderView.frame.height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableHeaderView
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPoint = indexPath.row
        self.enableSendButton()
        for index in 0 ..< points.count {
            cells[index].setSelected(index == self.selectedPoint)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
