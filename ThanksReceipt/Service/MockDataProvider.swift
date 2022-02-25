//
//  MockDataProvider.swift
//  ThanksReceipt
//
//  Created by Damor on 2022/02/23.
//

import Foundation
import Combine

final class MockDataProvider: DataProviding {
    
    private lazy var receiptList: CurrentValueSubject<[ReceiptItem], Error> = {
        CurrentValueSubject(
            [
                .init(id: UUID().uuidString, text: "좋은 친구들", date: makeDate("2022.02.25")),
                .init(id: UUID().uuidString, text: "출근 전 오전 운동 클리어🔥", date: makeDate("2022.02.25")),
                .init(id: UUID().uuidString, text: "일이 즐겁다 :)", date: makeDate("2022.02.25")),
                .init(id: UUID().uuidString, text: "감사 영수증 출시가 임박했다!!", date: makeDate("2022.02.24")),
                .init(id: UUID().uuidString, text: "매일 좋은 환경에서 일 할 수 있음에 감사~~", date: makeDate("2022.02.24")),
                .init(id: UUID().uuidString, text: "휴가를 다녀왔다 🌴", date: makeDate("2022.02.23")),
                .init(id: UUID().uuidString, text: "문득 매일매일이 행복하다는 생각이 들었다.", date: makeDate("2022.02.22")),
                .init(id: UUID().uuidString, text: "하루하루 열심히 살아야겠다😁", date: makeDate("2022.02.22")),
                .init(id: UUID().uuidString, text: "Thank God!", date: makeDate("2022.02.21")),
                .init(id: UUID().uuidString, text: "싱글벙글 팀 분위기, 좋은 동료들", date: makeDate("2022.02.21")),
                .init(id: UUID().uuidString, text: "좋은 친구들", date: makeDate("2022.02.20")),
                .init(id: UUID().uuidString, text: "출근 전 오전 운동 클리어🔥", date: makeDate("2022.02.20")),
                .init(id: UUID().uuidString, text: "일이 즐겁다 :)", date: makeDate("2022.02.20")),
                .init(id: UUID().uuidString, text: "감사 영수증 출시가 임박했다!!", date: makeDate("2022.02.19")),
                .init(id: UUID().uuidString, text: "매일 좋은 환경에서 일 할 수 있음에 감사~~", date: makeDate("2022.02.19")),
                .init(id: UUID().uuidString, text: "휴가를 다녀왔다 🌴", date: makeDate("2022.02.18")),
                .init(id: UUID().uuidString, text: "문득 매일매일이 행복하다는 생각이 들었다.", date: makeDate("2022.02.17")),
                .init(id: UUID().uuidString, text: "하루하루 열심히 살아야겠다😁", date: makeDate("2022.02.17")),
                .init(id: UUID().uuidString, text: "Thank God!", date: makeDate("2022.02.16")),
                .init(id: UUID().uuidString, text: "싱글벙글 팀 분위기, 좋은 동료들", date: makeDate("2022.02.15"))
            ]
        )
    }()
    
    private func makeDate(_ format: String) -> Date {
        let formatter = DateFormatter(format: .yearMonthDay)
        return formatter.date(from: format) ?? Date()
    }
    
    func create(receiptItem: ReceiptItem) throws -> String? {
        var item = receiptItem
        item.id = UUID().uuidString
        var values = receiptList.value
        values.append(item)
        receiptList.send(values)
        return item.id
    }
    
    func receiptItemList(in date: Date) -> AnyPublisher<[ReceiptItem], Error> {
        return receiptList.share(replay: 1).eraseToAnyPublisher()
    }
    
    func update(_ item: ReceiptItem) throws {
        throw DataError.custom("not supported")
    }
    
    func delete(id: String) throws {
        throw DataError.custom("not supported")
    }
    
    func delete(date: Date) throws {
        throw DataError.custom("not supported")
    }
}
