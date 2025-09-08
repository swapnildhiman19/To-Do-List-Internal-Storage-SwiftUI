//
//  To_Do_List_Internal_Storage_SwiftUIApp.swift
//  To-Do-List-Internal-Storage-SwiftUI
//
//  Created by Swapnil Dhiman on 24/07/25.
//

import SwiftUI
import CoreData

@main
struct To_Do_List_Internal_Storage_SwiftUIApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onChange(of: scenePhase) { oldValue, newValue in
                    // Save changes if app enters in background or inactive state
                    if newValue == .background {
                        // equivalent to app has reached applicationDidEnterBackground
                        print("App has entered in background. Saving the context")
                        saveContext()
                    }
                }
            /*
            Inject the Core Data Context into the Environment
             You need to make the Core Data context available to your SwiftUI views. Modify your main app file.
             */
        }
    }
    
    func saveContext() {
        let context = persistenceController.container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context when app goes in background: \(error)")
            }
        }
    }
}


