import UIKit
import SQLite3

class EmployeeDetailsViewController: UIViewController {
    
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfAge: UITextField!

    var employees = [EmployeeModel]()
    let databaseName = "bitcode.sqlite" //Step 3 - create Database Name
    var dbDetailsObject: OpaquePointer?
    let tableNameEmployee = "Employees"
 
    override func viewDidLoad() {
        super.viewDidLoad()
        openCreateDatabase() // To call this Function
        createEmployeeTableDB() // To call this Function
        //readData()
        
//Aim:- To store this following Details in DataBase and read it via DataBase
//        let e1 = Employee(id: 1, name: "Pratham", phoneNumber: "1234567899", age: 25)
//        employees.append(e1)
//        let e2 = Employee(id: 2, name: "Praful", phoneNumber: "9987654321", age: 26)
//        let e3 = Employee(id: 3, name: "Shivani", phoneNumber: "1123456789", age: 27)
//        let e4 = Employee(id: 4, name: "Rutu", phoneNumber: "2213456789", age: 28)
//        let e5 = Employee(id: 5, name: "Nikita", phoneNumber: "8897654321", age: 29)
//        employees.append(e2)
//        employees.append(e3)
//        employees.append(e4)
//        employees.append(e5)
        
        for employee in self.employees {
            insertDataInTable(employee: employee)
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
    //MARK: Step 3 - Create Employees Table in Database
    private func createEmployeeTableDB() {
        var opaquePointerObject_CreateTable: OpaquePointer?
        
        
        let createTableQuery = "CREATE TABLE \(tableNameEmployee)(ID INTEGER PRIMARY KEY, Name TEXT, PhoneNumber TEXT, Age INTEGER)"
        
        //Step-3.1 -> Preparing a Query -> we need query because sqlite understands a query language to communicate.
        // * Query has fixed Syntax
        if sqlite3_prepare_v2(self.dbDetailsObject,
                               createTableQuery,
                               -1,
                               &opaquePointerObject_CreateTable,
                               nil) == SQLITE_OK { /* Sqlite Ok used to check the query condition*/
        print("Query Prepared Successful")
            
            //Step-3.2 -> Execute Query -> If Successful
           if sqlite3_step(opaquePointerObject_CreateTable) == SQLITE_DONE { /* Sqlite Done used to execute an action  i.e To create Table */
                print("Table Employee Created Successfully")
            } else {
                print("Table Employee Not Created")
            }
            
       } else {
           print("Query Not Prepared. Some issue in Create Table Query. No proper Query Or Table Already Exists")
       }
    }
    //MARK: Step 4 - To Insert Data in Table
    private func insertDataInTable(employee: EmployeeModel) {
        var OpaquePointerInsertData: OpaquePointer?
        
        //(ID INTEGER, Name TEXT, PhoneNumber TEXT, Age INTEGER)
        let insertQuery = "INSERT INTO \(tableNameEmployee) VALUES(?,?,?,?)"
        // Prepare
       if sqlite3_prepare_v2(self.dbDetailsObject,
                           insertQuery,
                           -1,
                           &OpaquePointerInsertData,
                           nil) == SQLITE_OK {/* Sqlite Ok used to check the query condition*/
           // Conversions
           let id = Int32(employee.id)
           let name = (employee.name as NSString).utf8String
           let phoneNumber = (employee.phoneNumber as NSString).utf8String
           let age = Int32(employee.age)

           //Binding
           sqlite3_bind_int(OpaquePointerInsertData, 1, id) // Id
           sqlite3_bind_text(OpaquePointerInsertData,
                             2,
                             name,
                             -1,
                             nil) // Name
           sqlite3_bind_text(OpaquePointerInsertData,
                             3,
                             phoneNumber,
                             -1,
                             nil) // Phone Number
           sqlite3_bind_int(OpaquePointerInsertData, 4, age) // Age
           // step
           if sqlite3_step(OpaquePointerInsertData) == SQLITE_DONE { /* Sqlite Done used to execute an action  i.e To Inserting Data */
               print("Data Inserted Successfully")
           } else {
               print("Insert data Failed")
           }
           
       } else {
           print("Insert Query not Prepared")
       }
  
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
            if sqlite3_step(readStatement) == SQLITE_ROW {
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
                
            } else {
                print("Read Query NOT executed")
            }
           return employees
       } else {
           print("Read Query Compilation Failed")
           return [EmployeeModel]()
       }
    }
    
    
    private func presentSuccessAlert() {
        // Create new Alert
        let dialogMessage = UIAlertController(title: "DATA ADDED", message: "Employee Details Added Successfully?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
         })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)

        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }
    private func absentfailAlert() {
        // Create new Alert
        let dialogMessage = UIAlertController(title: "DATA Incomplete", message: "Employee Details Not Added", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
         })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)

        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func clearText() {
        
        tfID.text = ""
        tfName.text = ""
        tfPhoneNumber.text = ""
        tfAge.text = ""
        
    }
    
    @IBAction func saveEmployeeDetails() {
        //ID INTEGER PRIMARY KEY, Name TEXT, PhoneNumber TEXT, Age INTEGER
        let employeeId = Int(tfID.text ?? "") ?? 0
        let employeeName = tfName.text ?? ""
        let employeePhoneNumber = tfPhoneNumber.text ?? ""
        let employeeAge = Int(tfAge.text ?? "") ?? 0
        let employeeDataObject = EmployeeModel(id: employeeId, name: employeeName, phoneNumber: employeePhoneNumber, age: employeeAge)
        
        insertDataInTable(employee: employeeDataObject)
        
        if (employeeDataObject.name.count == 0) ||
            (employeeDataObject.id == 0) ||
            (employeeDataObject.phoneNumber.count == 0) ||
            (employeeDataObject.age == 0) {
            absentfailAlert()
        } else {
            presentSuccessAlert()
        }
        //yourTextFieldOutlet.text = ""  To Clear Text (Func created -> clearText)
        clearText()

    }    
}
