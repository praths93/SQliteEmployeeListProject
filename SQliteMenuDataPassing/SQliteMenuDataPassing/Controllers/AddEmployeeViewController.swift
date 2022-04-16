import UIKit
import SQLite3

class AddEmployeeViewController: UIViewController {
    
    var dbDetailsObject: OpaquePointer?
    let tableNameEmployee = "Employees"
    let databaseName = "bitcode.sqlite" //Step 3 - create Database Name


    override func viewDidLoad() {
        super.viewDidLoad()
        openCreateDatabase()
        

    }
    @IBAction func AddEmployeeButtonAction() {
        guard let vc2 = (self.storyboard?.instantiateViewController(withIdentifier: "EmployeeDetailsViewController")) else {
            return
        }
        self.navigationController?.pushViewController(vc2, animated: true)
        
    }
    @IBAction func EmployeeListButtonAction() {
        guard let vc3 = (self.storyboard?.instantiateViewController(withIdentifier: "DisplayEmployeeListViewController")) as? DisplayEmployeeListViewController else {
            return
        }
        vc3.employeeArray = readData()
        self.navigationController?.pushViewController(vc3, animated: true)
    }
    
    private func readData() -> [EmployeeModel] {
        var readStatement: OpaquePointer?
        let readQuery = "SELECT * FROM \(tableNameEmployee)"
        
        var employees = [EmployeeModel]()
        
       if sqlite3_prepare_v2(self.dbDetailsObject,
                           readQuery,
                           -1,
                           &readStatement,
                           nil) == SQLITE_OK {
            print("Read Query Compiled Successfully")
            while sqlite3_step(readStatement) == SQLITE_ROW {
                // (ID INTEGER PRIMARY KEY, Name TEXT, PhoneNumber TEXT, Age INTEGER)
               print("Read Query executed successfully")
                let idInt32 = sqlite3_column_int(readStatement, 0)
                let id = Int(idInt32)
           guard
                let nameCStr = sqlite3_column_text(readStatement, 1),
                let phoneNumberCStr = sqlite3_column_text(readStatement, 2)
                else {
                    return [EmployeeModel]()
                }
                let name = String(cString: nameCStr)
                let phoneNumber = String(cString: phoneNumberCStr)
                let ageInt32 = sqlite3_column_int(readStatement, 3)
                let age = Int(ageInt32)
                
                print("Employee Details:\nId: \(id),\nName:\(name),\nPhone Number: \(phoneNumber),\nAge: \(age)")
                
                let employee = EmployeeModel(id: id, name: name, phoneNumber: phoneNumber, age: age)
                employees.append(employee)
                
            }
           return employees
       } else {
           print("Read Query Compilation Failed")
           return [EmployeeModel]()
       }
    }
    
    //MARK: Step 2 - Create DataBase
   private func openCreateDatabase() {
        guard let dbPath = getPathForDocumentsDirectory() else{
            print("Documents Directory Path is Missing")
            return
        }
        print("DB Path: \(dbPath)")
       
       //Step2.1 - Importing SQLite3 and To check Database is Created or already present (bitcode.sqlite)
       var dbdetails: OpaquePointer?
       if sqlite3_open(dbPath,
                       &dbdetails) == SQLITE_OK { /* Sqlite Ok used to check the query condition*/
           print("Database is successfully created Or Already Present & we are able to access it/Open it")
           self.dbDetailsObject = dbdetails
       } else {
           print("Unable to Create Or Open DB")

       }
    }
    
    //MARK: Step 1 - To Get Path For Documents Directory
    private func getPathForDocumentsDirectory() -> String? {
        do{
            // Use to access Document Directory
            let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory,
                                                                   in: .userDomainMask,
                                                                   appropriateFor: nil,
                                                                   create: false)
            // To check where the Database is in documents Directory
            let dbPath = documentDirectoryURL.appendingPathComponent(self.databaseName)
            return dbPath.absoluteString
            
        } catch {
            print(error.localizedDescription)
            return nil
        }

    }
}
    
