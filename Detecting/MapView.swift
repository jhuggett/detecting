//
//  MapView.swift
//  Detecting
//
//  Created by Joel Huggett on 2024-03-17.
//

import Foundation
import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
	
	let onSelect: (_: Session) -> Void
	
		 
	init(onSelect: @escaping (_: Session) -> Void) {
		self.onSelect	= onSelect
	}
	
	var locationManager = LocationDataManager()
	@Environment(\.modelContext) private var context
	@Query() private var sessions: [Session]
	
        var body: some View {
            Map(initialPosition: MapCameraPosition.userLocation(fallback: MapCameraPosition.automatic)) {
								ForEach (sessions, id: \.id) { session in
//									Marker  ("Hello", coordinate: CLLocationCoordinate2D(latitude: session.lat, longitude: session.long))
//										.tint(.orange)
										
									Annotation("Session", coordinate: CLLocationCoordinate2D(latitude: session.lat, longitude: session.long)) {
																			ZStack {
																					RoundedRectangle(cornerRadius: 5)
																							.fill(Color.white)
																				VStack {
																				Button {
																					loadSession(session: session)
																				} label: {
																					Text("Resume")
																						.padding(3)
																				}
																				}

																			}
																	}
								}
                UserAnnotation()
                
            }
            
            .mapStyle(MapStyle.imagery)
            .mapControls {
                        MapCompass()
                    }
					
					Button("New Session", action: createSession)
        }
	
	func loadSession(session: Session) {
		onSelect(session)
	}
	
	func createSession() {
		
		guard let currentLocation = locationManager.currentLocation else { return }
		
		
		let session = Session(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude, elevation: currentLocation.altitude)
		
		context.insert(session)
												do {
														try context.save()
												} catch {
														print(error.localizedDescription)
												}
		
	
		
		
		
	}
}
