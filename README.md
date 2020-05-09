# CoreDataContextManager

A group of useful methods on top of core data context.

**Note:** this package may need some testing before using on a real project.

### Interface 

```swift
extension NSManagedObjectContext {

    public var manager: CoreDataContextManager { get }
}

public class CoreDataContextManager {

    public init(context: NSManagedObjectContext)
    
    //

    public func insert<ManagedObject>(_ object: ManagedObject) throws where ManagedObject : NSManagedObject

    public func delete<ManagedObject>(_ object: ManagedObject) throws where ManagedObject : NSManagedObject

    public func object<ManagedObject>(with objectID: NSManagedObjectID) throws -> ManagedObject where ManagedObject : NSManagedObject

    public func request<RequestResult>() -> RequestBuilder<RequestResult> where RequestResult : NSFetchRequestResult

    public func fetch<RequestResult>(_ fetchRequest: NSFetchRequest<RequestResult>) throws -> [RequestResult] where RequestResult : NSFetchRequestResult

    public func performAsync(_ block: @escaping () -> Void)

    public func save() throws

    public func transaction(_ transactionBlock: () throws -> Void) throws

	// Undo manager
	
    public var undoManager: UndoManager? { get set }

    public func undoGrouping(_ block: () -> Void)

    public func undoAll()

    public func undoLast()

    public func redo()

    public func reset()

    public func rollback()
}
```
