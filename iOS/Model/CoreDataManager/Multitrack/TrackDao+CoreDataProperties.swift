//
//  TrackDao.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 22/01/26.
//

import Foundation
import CoreData

@objc(TrackDao)
public class TrackDao: NSManagedObject {
    
}

extension TrackDao {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var relativePath: String?
    @NSManaged public var volume: Float
    @NSManaged public var pan: Float
    @NSManaged public var mute: Bool
    @NSManaged public var order: Int32
    @NSManaged public var multitrack: MultitrackDao?
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        mute = false
        volume = 0.5
        pan = 0.0
        order = 0
    }
}

