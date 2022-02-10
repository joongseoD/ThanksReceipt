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
    func create(receiptItem: ReceiptItem) throws {
        let realm = try Realm()
        let dataModel = Receipt(text: receiptItem.text, date: receiptItem.date)
        try realm.write {
            realm.add(dataModel)
        }
    }
    
    func receiptItemList() -> AnyPublisher<[ReceiptItem], Error> {
        return AnyPublisher<[ReceiptItem], Error>.create { subscriber in
            do {
                let realm = try Realm()
                let items = Array(realm.objects(Receipt.self).sorted(by: \.date, ascending: false))
                    .compactMap { receipt -> ReceiptItem? in
                        guard let date = receipt.date else { return nil }
                        return ReceiptItem(text: receipt.text, date: date)
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
    
    func update(id: String, _ item: ReceiptItem) throws {
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
