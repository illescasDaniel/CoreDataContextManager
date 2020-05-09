//
//  ManagedObjectUtils.swift
//  
//  MIT LICENSE
//  Created by Daniel Illescas Romero on 09/05/2020.
//

import class CoreData.NSManagedObject
import class Foundation.NSExpression

public protocol ManagedObjectUtils: NSManagedObject {
	func validateValue<V>(key: ReferenceWritableKeyPath<Self,V>, value: V) throws
}
public extension ManagedObjectUtils {
	func validateValue<V>(key: ReferenceWritableKeyPath<Self,V>, value: V) throws {
		var anyObject: AnyObject? = value as AnyObject
		try self.validateValue(&anyObject, forKey: NSExpression(forKeyPath: key).keyPath)
	}
}

public protocol IdentifiableManagedObject: ManagedObjectUtils, Identifiable {}
