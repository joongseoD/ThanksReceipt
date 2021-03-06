//
//  Array+Extensions.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/15.
//

import Foundation

extension Array where Element == ReceiptSectionModel {
    var totalCount: String {
        "\(itemsCount).00"
    }
    
    var itemsCount: Int {
        reduce(0) { count, sectionModel in count + sectionModel.count }
    }
}

extension Array where Element == ReceiptRowModel {
    func mapToSectionModel(dependency: ReceiptSectionModelDependency = ReceiptSectionModelComponents()) -> [ReceiptSectionModel] {
        self.reduce([]) { sectionModels, itemModel -> [ReceiptSectionModel] in
            var sectionModels = sectionModels
            if let index = sectionModels.firstIndex(where: { $0.dateString == itemModel.dateString }) {
                sectionModels[index].items.append(itemModel)
                return sectionModels
            } else {
                sectionModels.append(ReceiptSectionModel(header: itemModel, items: [], dependency: dependency))
            }
            return sectionModels
        }
    }
}
