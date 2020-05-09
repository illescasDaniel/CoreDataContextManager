//
//  RequestBuilder.swift
//  
//  MIT LICENSE
//  Created by Daniel Illescas Romero on 09/05/2020.
//

import class Foundation.NSPredicate

import class CoreData.NSManagedObject
import class CoreData.NSFetchRequest
import class CoreData.NSSortDescriptor
import class CoreData.NSBatchDeleteRequest
import class CoreData.NSAsynchronousFetchResult
import class CoreData.NSAsynchronousFetchRequest
import protocol CoreData.NSFetchRequestResult

public class RequestBuilder<RequestResult: NSFetchRequestResult> {
	
	private let fetchRequest = NSFetchRequest<RequestResult>()
	
	public init() {
		if let ManagedObject = RequestResult.self as? NSManagedObject.Type, #available(OSX 10.12, *) {
			fetchRequest.entity = ManagedObject.entity()
		}
	}
	
	public func limit(_ limit: Int) -> Self {
		self.fetchRequest.fetchLimit = limit < 0 ? 1 : limit
		return self
	}
	
	public func offset(_ offset: Int) -> Self {
		self.fetchRequest.fetchOffset = offset < 0 ? 0 : offset
		return self
	}
	
	public func page(_ page: Int, size: Int) -> Self {
		return offset(page * size)
			  .limit(size)
	}
	
	public func batchSize(_ batchSize: Int) -> Self {
		self.fetchRequest.fetchBatchSize = batchSize
		return self
	}
	
	public func orderBy(_ sortDescriptor: [NSSortDescriptor]) -> Self {
		self.fetchRequest.sortDescriptors = sortDescriptor
		return self
	}
	
	public func `where`(_ predicate: NSPredicate) -> Self {
		self.fetchRequest.predicate = predicate
		return self
	}
	
	public func groupBy(
		_ predicate: NSPredicate,
		propertiesToGroupBy: [PartialKeyPath<RequestResult>]? = nil
	) -> Self {
		if let properties = propertiesToGroupBy {
			self.propertiesToGroupBy(properties)
		}
		self.fetchRequest.havingPredicate = predicate
		return self
	}
	
	public func propertiesToFetch(_ propertiesToFetch: [PartialKeyPath<RequestResult>]) -> Self {
		self.fetchRequest.propertiesToFetch = propertiesToFetch.compactMap { $0._kvcKeyPathString }
		self.fetchRequest.resultType = .dictionaryResultType
		return self
	}
	
	public func options(
		block: (NSFetchRequest<RequestResult>) -> Void
	) -> Self {
		block(self.fetchRequest)
		return self
	}

	/// Same as `buildFetchRequest()`
	public func build() -> NSFetchRequest<RequestResult> {
		return buildFetchRequest()
	}
	
	/// Same as `build()`
	public func buildFetchRequest() -> NSFetchRequest<RequestResult> {
		return fetchRequest
	}
	
	@available(OSX 10.11, *)
	public func buildDeleteFetchRequest() -> NSBatchDeleteRequest {
		return NSBatchDeleteRequest(fetchRequest: self.fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
	}
	
	public func buildAsyncFetchRequest(_ completionBlock: @escaping (NSAsynchronousFetchResult<RequestResult>) -> Void) -> NSAsynchronousFetchRequest<RequestResult> {
		NSAsynchronousFetchRequest<RequestResult>(fetchRequest: self.fetchRequest, completionBlock: completionBlock)
	}
	
	// MARK: Convenience
	
	@discardableResult
	private func propertiesToGroupBy(_ propertiesToGroupBy: [PartialKeyPath<RequestResult>]) -> Self {
		self.fetchRequest.propertiesToGroupBy = propertiesToGroupBy.compactMap { $0._kvcKeyPathString }
		self.fetchRequest.resultType = .dictionaryResultType
		return self
	}
}
