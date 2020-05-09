//
//  CoreDataContextManager.swift
//
//  MIT LICENSE
//  Created by Daniel Illescas Romero on 09/05/2020.
//

import class Foundation.UndoManager

import class CoreData.NSManagedObjectContext
import class CoreData.NSManagedObject
import class CoreData.NSManagedObjectID
import class CoreData.NSFetchRequest
import protocol CoreData.NSFetchRequestResult

extension NSManagedObjectContext {
	public var manager: CoreDataContextManager {
		.init(context: self)
	}
}

public class CoreDataContextManager {
	
	private var context: NSManagedObjectContext
	
	public init(context: NSManagedObjectContext) {
		self.context = context
	}
	
	public func insert<ManagedObject: NSManagedObject>(_ object: ManagedObject) throws {
		try object.validateForInsert()
		self.context.insert(object)
	}
	
	public func delete<ManagedObject: NSManagedObject>(_ object: ManagedObject) throws {
		try object.validateForDelete()
		self.context.delete(object)
	}
	
	public func object<ManagedObject: NSManagedObject>(with objectID: NSManagedObjectID) throws -> ManagedObject {
		try self.context.existingObject(with: objectID) as! ManagedObject
	}
	
	public func request<RequestResult: NSFetchRequestResult>() -> RequestBuilder<RequestResult> {
		return RequestBuilder<RequestResult>()
	}
	
	public func fetch<RequestResult: NSFetchRequestResult>(_ fetchRequest: NSFetchRequest<RequestResult>) throws -> [RequestResult] {
		try self.context.fetch(fetchRequest)
	}
	
	public func performAsync(_ block: @escaping () -> Void) {
		self.context.perform(block)
	}
	
	public func save() throws {
		guard self.context.hasChanges else { return }
		try context.save()
	}
	
	public func transaction(_ transactionBlock: () throws -> Void) throws {
		do {
			try self.save()
			try transactionBlock()
			try self.save()
		} catch {
			self.rollback()
			throw error
		}
	}
	
	// MARK: UndoManager
	
	public var undoManager: UndoManager? {
		get { self.context.undoManager }
		set { self.context.undoManager = newValue }
	}
	
	public func undoGrouping(_ block: () -> Void) {
		
		let undoManager: UndoManager
		if let contextUndoManager = self.undoManager {
			undoManager = contextUndoManager
		} else {
			undoManager = UndoManager()
			undoManager.groupsByEvent = false
			self.undoManager = undoManager
		}
		
		undoManager.beginUndoGrouping()
		block()
		undoManager.endUndoGrouping()
	}
	
	public func undoAll() {
		self.context.undo()
	}
	
	public func undoLast() {
		self.context.undoManager?.undoNestedGroup()
	}
	
	public func redo() {
		self.context.redo()
	}

	public func reset() {
		self.context.reset()
	}

	public func rollback() {
		self.context.rollback()
	}
}
