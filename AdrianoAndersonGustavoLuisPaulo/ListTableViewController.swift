//
//  ListTableViewController.swift
//  AdrianoAndersonGustavoLuisPaulo
//
//  Created by f6365418 on 16/10/22.
//

import UIKit
import Firebase

class ListTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let collection = "toysList"
    private var toysList: [ToyItem] = []
    private lazy var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    
    var firestoreListener: ListenerRegistration!

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadToyList()
    }
    
    //MARK: - Methods
    private func loadToyList() {
        firestoreListener = firestore
                            .collection(collection)
                            .order(by: "name", descending: false)
//                                .limit(to: 20)
                            .addSnapshotListener(includeMetadataChanges: true, listener: { snapshot, error in
                                if let error = error {
                                    print(error)
                                } else {
                                    guard let snapshot = snapshot else { return }
                                    print("Total de documentos alterados:", snapshot.documentChanges.count)
                                    if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                                        self.showItemsFrom(snapshot: snapshot)
                                    }
                                }
                            })
    }
    
    private func showItemsFrom(snapshot: QuerySnapshot) {
        toysList.removeAll()
        print("toyList_1 \(toysList)")
        for document in snapshot.documents {
            let id = document.documentID
            let data = document.data()
            let name = data["name"] as? String ?? "---"
            let phone = data["phone"] as? String ?? "() XXXXX-XXXX"
            let toyItem = ToyItem(id: id, name: name, phone: phone)
            toysList.append(toyItem)
        }
        print("toyList_2: \(toysList)")
        tableView.reloadData()
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("cell count: \(toysList.count)")
        return toysList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let toyItem = toysList[indexPath.row]
        
        cell.textLabel?.text = toyItem.name
        cell.detailTextLabel?.text = toyItem.phone
        print("cell: \(cell)")
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
