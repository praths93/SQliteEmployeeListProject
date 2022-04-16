
import UIKit

class EmployeeListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var employeeNameLabel: UILabel!
    
    @IBOutlet weak var employeeIdLabel: UILabel!
    
    @IBOutlet weak var employeePhoneNumberLabel: UILabel!
    
    @IBOutlet weak var employeeAgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
