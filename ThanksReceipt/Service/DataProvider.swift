//
//  DataProvider.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/08.
//

import Combine
import CombineExt
import RealmSwift

enum DataError: Error, CustomStringConvertible {
    case realm
    case custom(_ message: String)
    
    var description: String {
        switch self {
        case .realm: return "데이터 읽기에 실패했습니다."
        case let .custom(message): return message
        }
    }
}

extension Error {
    var dataErrorDescription: String {
        guard let error = self as? DataError else { return localizedDescription }
        return error.description
    }
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
    
    func create(receiptItem: ReceiptItem) throws -> String? {
        let realm = try Realm()
        let dataModel = Receipt(text: receiptItem.text, date: receiptItem.date, createdDate: Date())
        try realm.write {
            realm.add(dataModel)
        }
        return dataModel.id
    }
    
    func receiptItemList(in date: Date) -> AnyPublisher<[ReceiptItem], Error> {
        return AnyPublisher<[ReceiptItem], Error>.create { subscriber in
            do {
                let realm = try Realm()
                let sortProperties = [SortDescriptor(keyPath: "date", ascending: true),
                                      SortDescriptor(keyPath: "createdDate", ascending: true)]
                
                let items = Array(realm.objects(Receipt.self)
                                    .filter("date BETWEEN {%@, %@}", date.startOfMonth, date.endOfMonth)
                                    .sorted(by: sortProperties))
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
        guard let id = item.id, let updatingModel = realm.objects(Receipt.self).filter("id = %@", id).first else {
            throw DataError.custom("삭제할 대상이 잘못되었습니다.")
        }
        
        try realm.write {
            updatingModel.text = item.text
            updatingModel.date = item.date
        }
    }
    
    func delete(id: String) throws {
        let realm = try Realm()
        try realm.write {
            realm.delete(realm.objects(Receipt.self).filter("id = %@", id))
        }
    }
    
    func delete(date: Date) throws {
        let realm = try Realm()
        try realm.write {
            realm.delete(
                realm.objects(Receipt.self)
                    .filter("date BETWEEN {%@, %@}", date.startOfDay, date.endOfDay)
            )
        }
    }
}
