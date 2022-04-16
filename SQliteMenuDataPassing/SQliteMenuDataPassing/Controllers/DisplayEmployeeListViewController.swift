
import UIKit

class DisplayEmployeeListViewController: UIViewController {
    
    @IBOutlet weak var employeeTable: UITableView!
    
    var employeeArray: [EmployeeModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.employeeTable.dataSource = self
        self.employeeTable.delegate = self

        let EmployeeListTableViewCellXib = UINib(nibName: "EmployeeListTableViewCell",
                                                bundle: nil)
        employeeTable.register(EmployeeListTableViewCellXib, forCellReuseIdentifier:                                                         "EmployeeListTableViewCell")
       // self.employeeTable.reloadData()
    }
 
}
//MARK: UITableViewDataSource
extension DisplayEmployeeListViewController: UITableViewDataSource {
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       self.employeeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "EmployeeListTableViewCell"
        guard let cell = self.employeeTable.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EmployeeListTableViewCell
        else {
            return UITableViewCell()
        }
        let employeeIndex = employeeArray[indexPath.row]
        cell.employeeNameLabel.text = employeeIndex.name
        cell.employeeIdLabel.text = "\(employeeIndex.id)"
        cell.employeePhoneNumberLabel.text = employeeIndex.phoneNumber
        cell.employeeAgeLabel.text = "\(employeeIndex.age)"
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension DisplayEmployeeListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
}
