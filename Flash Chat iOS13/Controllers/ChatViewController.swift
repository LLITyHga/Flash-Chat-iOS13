//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()//створюємо посилання на базу даних в класі(як іспользовать написано на сайті в Cloud Firestore)
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self//вказуємо що обєкт діє як джерело дантх для таблиці в поточному класі
        title = K.appName
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)//реєстрація тейблвієва (аутлєта) в дідлоаді за допомогою назви файлу xib в якому находиця намальований тейблвієв. forCellReuse.... це слово ідентифікатор придумане від фанаря і вписане в тейблвієві справа є поле "identifier"
        loadMessages()

    }
    
    func loadMessages() {
       
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in//addSnapshot перегляд фаєрстора в реальному часі, order це сортіровка в отображенії(взята з докс на сайті)
            self.messages = []
            if let e = error {
                print(e)
            }else {
               // print(querySnapshot?.documents[0].data()[K.FStore.senderField])зараз воно Optional
               // print(querySnapshot?.documents[0].data()[K.FStore.bodyField])треба розгорнути
                if let snapshotDocumet = querySnapshot?.documents {
                    for doc in snapshotDocumet {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String{
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {//коли получим дані з інтернета це ставить кусок кода першим в очередь
                                self.tableView.reloadData()//повторно визиває метод в дідлоаді
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)//це метод ля функції скрол ту ров де в дужках прописуєця до куда нада прокручувати
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                            
                        }}
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email/*цю фігню вона нашла в Docs HA Firebase в розділі Message Users + переменні Optional тому використовуєм іф лет*/{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970])
            { (error) in
                if let e = error {//в дужках після колектіон назва придумана от балди, аддДокумент метод з фаєрбази в даному випадку передає масив ключ-пєрємєнна(ключ придуманий так само)
                    print(e)
                }else{
                    print("дані збережено")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                } 
            }
        }
    }
    

    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {
        
    do {
      try Auth.auth().signOut()
        navigationController?.popToRootViewController(animated: true)
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
      
    }
}
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {//кількість комірок
        return messages.count// в даному випадку стільки скільки сообщеній
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//метод створює комірки
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell  //делаєм тип данних перємєнной того класа шо і аутлєт до якого ми звертаємся
        cell.label.text = message.body//шоб в нас був доступ до всіх елементів в тейблвієві
        if message.sender == Auth.auth().currentUser?.email{//проверка хто отправляє (Auth взали з того місця де ми отправляли дані в фаєрбазу зверху)
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
    
}


