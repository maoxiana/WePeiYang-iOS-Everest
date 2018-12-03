//
//  LibraryModel.swift
//  WePeiYang
//
//  Created by Halcao on 2018/2/3.
//  Copyright © 2018年 twtstudio. All rights reserved.
//

import Foundation

struct LibraryResponse: Codable {
    let errorCode: Int
    let data: BorrowingData
    let message: String

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case data = "data"
        case message = "message"
    }
}

struct BorrowingData: Codable {
    let status: String
    let expire: String
    let credit: String
    private let books_wrapper: [LibraryBook]?
    var books: [LibraryBook] {
        return books_wrapper ?? []
    }
    let card: String
    let borrowLimit: Int
    let type: String
    let borrowAmount: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case expire = "expire"
        case credit = "credit"
        case books_wrapper = "books"
        case card = "card"
        case borrowLimit = "borrowLimit"
        case type = "type"
        case borrowAmount = "borrowAmount"
        case name = "name"
    }

//    init(from decoder: Decoder) throws {
//        self.init(from: decoder)
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        books = try container.decodeNil(forKey: .books) ? [] : try container.decode([LibraryBook].self, forKey: .books)
//    }
}

struct LibraryBook: Codable {
    let author: String
    let callno: String
    let barcode: String
    let title: String
    let local: String
    let loanTime: String
    let type: String
    let returnTime: String
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case author
        case callno
        case barcode
        case title
        case local
        case loanTime
        case type
        case returnTime
        case id
    }
}

// MARK: Convenience initializers

extension LibraryResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(LibraryResponse.self, from: data)
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else { return nil }
        try self.init(data: data)
    }

    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    func jsonString() throws -> String? {
        return String(data: try self.jsonData(), encoding: .utf8)
    }
}

extension BorrowingData {
    init(data: Data) throws {
        self = try JSONDecoder().decode(BorrowingData.self, from: data)
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else { return nil }
        try self.init(data: data)
    }

    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    func jsonString() throws -> String? {
        return String(data: try self.jsonData(), encoding: .utf8)
    }
}

extension LibraryBook {
    init(data: Data) throws {
        self = try JSONDecoder().decode(LibraryBook.self, from: data)
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else { return nil }
        try self.init(data: data)
    }
}
