import Foundation
import RealmSwift

class RealmManager {
    static let privateInstance = RealmManager()
    static var shared : RealmManager {
        return privateInstance
    }
    private init() {}
    
    let realm = try! Realm(configuration: Realm.Configuration(objectTypes: [
        RealmListObject<MovieDTO>.self,
        RealmObject<MovieDTO>.self,
        MovieDTO.self,
        Cast.self
        
    ]))
    
    func save<T: Object>(object: T , with key: String){
        let data =  RealmObject<T>()
        data.key = key
        data.object = object

        try? realm.write(){
            realm.add(data, update: .all)
        }
    }

    func load<T: Object>(with key: String) -> T?{
        return realm.object(ofType: RealmObject<T>.self, forPrimaryKey: key)?.object
    }


    func saveList<T: Object>(object: [T] , with key: String){
        let data =  RealmListObject<T>()
        let list = List<T>()
        list.append(objectsIn: object)
        data.key = key
        data.object = list
        try? realm.write(){
            realm.add(data, update: .all)
        }
    }

    func loadList<T: Object>(with key: String) -> [T]{
        let reslut =  realm.object(ofType: RealmListObject<T>.self, forPrimaryKey: key)?.object.map{$0} ?? []
        return reslut
    }
    
}
