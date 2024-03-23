//
//  DetectingApp.swift
//  Detecting
//
//  Created by Joel Huggett on 2024-01-27.
//

import SwiftUI

@main
struct DetectingApp: App {
	
	@State private var currentSession: Session? = nil
	
    var body: some Scene {
        WindowGroup {
					if let currentSession = currentSession {
						ContentView(currentSession: currentSession, goBack: {
							self.currentSession = nil
						})
							.modelContainer(for: [
																	Session.self
															])
					} else {
						MapView(onSelect: { session in
							currentSession = session
						})
							.modelContainer(for: [
																	Session.self
															])
					}


						
        }
    }
}

