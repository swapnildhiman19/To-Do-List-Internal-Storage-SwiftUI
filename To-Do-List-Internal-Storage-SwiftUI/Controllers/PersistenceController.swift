//
//  PersistenceController.swift
//  To-Do-List-Internal-Storage-SwiftUI
//
//  Created by EasyAiWithSwapnil on 07/09/25.
//

// PersistenceController.swift
import CoreData

struct PersistenceController {
    
    let container: NSPersistentContainer
    
    static let shared = PersistenceController()
    
    /*
     init(inMemory: Bool = false): This is the start of the instructions. It asks a simple question: "Are we building a real, permanent filing cabinet, or a temporary, disposable one for practice?" By default (false), it builds a real one. The temporary option is great for testing or for SwiftUI Previews, so you don't fill your real storage with test data.
     
     container = NSPersistentContainer(name: "Model"): This line says, "Get the blueprint named 'Model' to build the cabinet." This name must match your .xcdatamodeld file, which defines what your data looks like (e.g., an Item has a string and isChecked status).
     
     if inMemory { ... }: If you asked for a temporary cabinet, this instruction says: "Instead of putting the cabinet in the main office (phone storage), just set it up in a temporary space that gets thrown away later (/dev/null)."
     
     container.loadPersistentStores { ... }: This is the most important step: "Actually build the cabinet and set it up." The code inside the {...} is a check: "If there was any problem during setup (like a broken part), stop everything and report the error."
     
     
     container.viewContext.automaticallyMergesChangesFromParent = true: This is a rule for the cabinet: "If data is updated in the background (e.g., from iCloud), automatically update the data you're currently looking at on your desk (viewContext)." It keeps everything in sync effortlessly.
     */
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ItemModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), error info: \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
