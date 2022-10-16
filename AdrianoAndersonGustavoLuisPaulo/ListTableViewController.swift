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
    
    private func showAlertForItem(_ item: ToyItem?) {
        let alert = UIAlertController(title: "Produto", message: "Entre com as informações do produto abaixo", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nome do brinquedo"
            textField.text = item?.name
        }
        alert.addTextField { textField in
            textField.placeholder = "Telefone do doador"
            textField.text = item?.phone
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let name = alert.textFields?.first?.text,
                  let phoneNumber = alert.textFields?.last?.text else {return}
            
            let data: [String: String] = [
                "name": name,
                "phone": phoneNumber
            ]
            
            if let item = item {
                //Edição
                self.firestore.collection(self.collection).document(item.id).updateData(data)
            } else {
                //Criação
                self.firestore.collection(self.collection).addDocument(data: data)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toyItem = toysList[indexPath.row]
        showAlertForItem(toyItem)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let toyItem = toysList[indexPath.row]
            firestore.collection(collection).document(toyItem.id).delete()
        }
    }

    //MARK: -IBActions
    @IBAction func addItem(_ sender: Any) {
        showAlertForItem(nil)
    }

}
