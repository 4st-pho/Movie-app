import RealmSwift
import Foundation

class RealmObject<T : Object>: Object {
    @Persisted(primaryKey: true) var key: String
    @Persisted var object: T?
}
class RealmListObject<T : Object>: Object {
    @Persisted(primaryKey: true) var key: String
    @Persisted var object: List<T>
}
