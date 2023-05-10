//
//  RealmManager.swift
//  Realm-Example
//
//  Created by mert can çifter on 9.05.2023.
//

import Foundation
import Realm
import RealmSwift


class RealmManager {
    
    static let shared = RealmManager()

    func readAll<T: Object>(_ type: T.Type) -> Results<T>? {
        if !isRealmAccessible() { return nil }

        let realm = getRealm()
        realm.refresh()

        return realm.objects(T.self)
    }
    
    func read<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) -> Results<T>? {
        if !isRealmAccessible() { return nil }

        let realm = getRealm()
        realm.refresh()

        return predicate == nil ? realm.objects(type) : realm.objects(type).filter(predicate!)
    }

    func create<T: Object>(_ data: T) {
        if !isRealmAccessible() { return }

        let realm = getRealm()
        realm.refresh()
        
        do {
            try realm.write({
                realm.add(data)
            })
        } catch let error {
            
        }
    }
    
    func update<T: Object>(_ data: T, with dictionary: [String: Any?]) {
        if !isRealmAccessible() { return }

        let realm = getRealm()
        realm.refresh()
        
        do {
            try realm.write({
                for (key, value) in dictionary {
                    data.setValue(value, forKey: key)
                }
            })
        } catch let error {
            
        }
    }

    func delete<T: Object>(_ data: T) {
        let realm = getRealm()
        realm.refresh()
        try? realm.write { realm.delete(data) }
    }

    func clearAllData() {
        if !isRealmAccessible() { return }

        let realm = getRealm()
        realm.refresh()
        try? realm.write { realm.deleteAll() }
    }
}

extension RealmManager {
    
    private func getRealm() -> Realm {
        if let _ = NSClassFromString("TODO") {
            
            return try! Realm(configuration: Realm.Configuration(fileURL: nil, inMemoryIdentifier: "todo", encryptionKey: nil, readOnly: false, schemaVersion: 0, migrationBlock: nil, objectTypes: nil))
        } else {
            return try! Realm();
        }
    }
    
    private func isRealmAccessible() -> Bool {
        do { _ = try Realm() } catch {
            print("Realm is not accessible")
            return false
        }
        return true
    }
}
