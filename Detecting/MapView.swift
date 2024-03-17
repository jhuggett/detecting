//
//  MapView.swift
//  Detecting
//
//  Created by Joel Huggett on 2024-03-17.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    
        var body: some View {
            Map(initialPosition: MapCameraPosition.userLocation(fallback: MapCameraPosition.automatic)) {
//                Marker("San Francisco City Hall", coordinate: cityHallLocation)
//                    .tint(.orange)
//                Marker("San Francisco Public Library", coordinate: publicLibraryLocation)
//                    .tint(.blue)
//                Annotation("Diller Civic Center Playground", coordinate: playgroundLocation) {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 5)
//                            .fill(Color.yellow)
//                        Text("🛝")
//                            .padding(5)
//                    }
//                }
                UserAnnotation()
                
            }
            
            .mapStyle(MapStyle.imagery)
            .mapControls {
                        MapCompass()
                    }
        }
    }
