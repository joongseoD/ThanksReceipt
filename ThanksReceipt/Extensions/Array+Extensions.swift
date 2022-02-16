//
//  Array+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import Foundation

extension Array where Element == ReceiptSectionModel {
    var totalCount: String {
        let count = reduce(0) { count, sectionModel in count + sectionModel.count }
        return "\(count).00"
    }
}

extension Array where Element == ReceiptItemModel {
    func mapToSectionModel() -> [ReceiptSectionModel] {
        self.reduce([]) { sectionModels, itemModel -> [ReceiptSectionModel] in
            var sectionModels = sectionModels
            if let index = sectionModels.firstIndex(where: { $0.date == itemModel.date }) {
                sectionModels[index].items.append(itemModel)
                return sectionModels
            } else {
                sectionModels.append(ReceiptSectionModel(header: itemModel, items: []))
            }
            return sectionModels
        }
    }
}