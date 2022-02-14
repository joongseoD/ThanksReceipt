//
//  DataProvider.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Combine
import CombineExt
import RealmSwift

enum DataError: Error {
    case realm
    case custom(_ message: String)
}

final class DataProvider: DataProviding {
    
    private let schemeVersion: UInt64 = 1
    
    init() {
        dataMigrationIfNeeded()
    }
    
    private func dataMigrationIfNeeded() {
        let config = Realm.Configuration(schemaVersion: schemeVersion) { [weak self] migration, oldSchemaVersion in
            guard let self = self else { return }
            print("## Scheme \(oldSchemaVersion) / \(self.schemeVersion)")
            guard oldSchemaVersion < self.schemeVersion else { return }
            migration.enumerateObjects(ofType: Receipt.className()) { oldObject, newObject in
                // do something
            }
        }
        Realm.Configuration.defaultConfiguration = config
    }
    
    func create(receiptItem: ReceiptItem) throws {
        let realm = try Realm()
        let dataModel = Receipt(text: receiptItem.text, date: receiptItem.date, createdDate: Date())
        try realm.write {
            realm.add(dataModel)
        }
    }
    
    func receiptItemList() -> AnyPublisher<[ReceiptItem], Error> {
        return AnyPublisher<[ReceiptItem], Error>.create { subscriber in
            do {
                let realm = try Realm()
                let sortProperties = [SortDescriptor(keyPath: "date", ascending: false),
                                      SortDescriptor(keyPath: "createdDate", ascending: false)]
                
                let items = Array(realm.objects(Receipt.self).sorted(by: sortProperties))
                    .compactMap { receipt -> ReceiptItem? in
                        return ReceiptItem(dataModel: receipt)
                    }
                
                subscriber.send(items)
                subscriber.send(completion: .finished)
                
                return AnyCancellable { }
            } catch {
                subscriber.send(completion: .failure(DataError.realm))
                return AnyCancellable { }
            }
        }
    }
    
    func update(_ item: ReceiptItem) throws {
        let realm = try Realm()
        let receipt = Receipt(model: item)
        try realm.write {
            realm.add(receipt, update: .modified)
        }
    }
    
    func delete(id: String) throws {
        let realm = try Realm()
        let receipt = Receipt(id: id)
        try realm.write {
            realm.delete(receipt)
        }
    }
}
