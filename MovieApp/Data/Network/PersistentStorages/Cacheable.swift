import Foundation

protocol Cacheable {
    associatedtype ObjectType
    
    func load(with key: String) -> ObjectType?
    func save(object: ObjectType, with key: String)
    func loadList(with key: String) -> ObjectType?
    func saveList(object: ObjectType, with key: String)
}
extension Cacheable {
    func load(with key: String) -> ObjectType? { return nil }
    func save(object: ObjectType, with key: String) {}
    func loadList(with key: String) -> ObjectType? { return nil }
    func saveList(object: ObjectType, with key: String){}
}
