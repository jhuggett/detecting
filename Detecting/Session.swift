//
//  Session.swift
//  Detecting
//
//  Created by Joel Huggett on 2024-03-19.
//

import Foundation
import SwiftData
import CoreLocation

@Model
class Session {
	var lat: Double
	var long: Double
	var elevation: Double
	
	init(lat: Double, long: Double, elevation: Double) {
		self.lat = lat
		self.long = long
		self.elevation = elevation
	}
}

