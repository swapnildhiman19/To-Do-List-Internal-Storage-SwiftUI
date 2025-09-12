//
//  ContentView.swift
//  To-Do-List-Internal-Storage-SwiftUI
//
//  Created by Swapnil Dhiman on 24/07/25.
//

import SwiftUI

/*
 
 //MARK: Implementing using UserDefaults
 
 struct ToDoList: Identifiable, Codable {
 let id = UUID()
 var string: String
 var isChecked : Bool = false
 }
 
 struct ContentView: View {
 //    @State var pendignItems : [ToDoList] = [
 //        ToDoList(string: "Learn AI from scratch"),
 //        ToDoList(string: "iOS"),
 //        ToDoList(string: "Resume building"),
 //        ToDoList(string: "Learn Flutter"),
 //        ToDoList(string: "Interview preparation"),
 //        ToDoList(string: "DSA")
 //    ]
 let defaultsKey = "ToDoList"
 @State var pendignItems : [ToDoList] = []
 
 @State private var showAddAlert: Bool = false
 @State private var newItemText: String = ""
 
 var body: some View {
 NavigationStack {
 // Need to have Binding concept since UI will also be updating the dataSource
 List{ ForEach($pendignItems)
 { $item in
 HStack {
 Text(item.string)
 Spacer()
 if item.isChecked {
 Image(systemName: "checkmark.circle.fill")
 .foregroundColor(.green)
 }
 }
 .contentShape(Rectangle()) // Make the entire row tappable
 .onTapGesture {
 item.isChecked.toggle() // Toggle the isChecked state
 saveItems()
 }
 }
 .onDelete(perform: deleteItems)
 }
 .navigationTitle("To Do List")
 /*
  Where to Place .navigationTitle()?
  You are right to question this! While putting .navigationTitle("To Do List") at the end of the List works, it can feel a bit strange. Here’s the rule:
  
  The .navigationTitle() modifier needs to be placed on a view that is inside a NavigationStack (or NavigationView).
  
  It finds the nearest navigation container "up the tree" and sets its title.
  
  Best Practice: It's common and clearer to attach it directly to the main content view inside the NavigationStack, which in this case is the List. So, your current placement is perfectly fine and standard practice. Placing it on the NavigationStack itself will not work, as the modifier needs to be on the content within the stack.
  */
 .toolbar {
 ToolbarItem(placement: .topBarTrailing) {
 Button(action: {
 showAddAlert = true
 }) {
 Image(systemName: "plus")
 }
 }
 }
 // will automatically show the alert when showAddAlert is true
 .alert("Add New Item", isPresented: $showAddAlert) {
 TextField("New Item", text: $newItemText)
 
 Button("Add", role:.confirm){
 if !newItemText.isEmpty {
 let newItem = ToDoList(string: newItemText)
 pendignItems.append(newItem)
 saveItems()
 newItemText = "" // Reset the text field
 }
 }
 
 Button("Cancel", role:.cancel) {
 newItemText = "" // Reset the text field
 }
 
 } message: {
 Text("Please enter the new item")
 }
 }
 .onAppear(perform: loadItems)
 }
 func saveItems() {
 //save the items in UserDefaults
 // Using JSONEncoder to convert the ItemsDetails -> "Data" format
 UserDefaults.standard.set(try? JSONEncoder().encode(pendignItems), forKey: defaultsKey)
 }
 func loadItems() {
 // need to use JSONDecoder to convert the "Data" from Defaults to struct ToDoList
 let savedData = UserDefaults.standard.data(forKey: defaultsKey) ?? Data()
 let decoder = JSONDecoder()
 let decodedItems: [ToDoList]? = try? decoder.decode([ToDoList].self, from: savedData)
 if let decodedItems = decodedItems {
 pendignItems = decodedItems
 }
 
 print(print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String))
 }
 func deleteItems(at offsets: IndexSet) {
 pendignItems.remove(atOffsets: offsets)
 saveItems()
 }
 }
 */

/*
 MARK: Implementing using Core Data
 */

import CoreData

struct ToDoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)])
    private var pendingItems : FetchedResults<Item>
    
    @State private var showAddAlert : Bool = false
    @State private var newItemText : String = ""
    
    @State private var searchText: String = "" // Adding the state for search text
    
    private var filteredPendingItems : [Item] {
        if searchText.isEmpty {
            return pendingItems.map { $0 } // Convert the FetchedResults<Item> into [Item]
        } else {
            // filter the items. Similar to NSPredicate in UIKit Swift implementation
            // 'localizationCaseInsensititveCotnains' is like 'contains[cd]' in NSPredicate.
            return pendingItems.filter {
                $0.string?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredPendingItems){ item in
                    HStack {
                        /*
                         Validation vs. Type System: The "non-optional" setting in Core Data is primarily a validation rule. It's enforced when you try to save the NSManagedObjectContext. If you try to save an Item where string is nil, the save operation will fail. However, it doesn't change the property's type in the generated Swift code. The Swift compiler doesn't know about this save-time rule at compile-time.
                         Object Lifecycle: It's possible to have an Item object in memory that hasn't been fully populated yet. You could create a new Item (let newItem = Item(context: viewContext)) but not set its string property immediately. In that moment, newItem.string is nil. If the property were a non-optional String, this state would be impossible and would crash your app.
                         Data Integrity: Your database could contain old data that was saved before you made the attribute non-optional. Swift's optionality protects your app from crashing if it fetches one of these old records where string is nil.
                         */
                        if let title = item.string {
                            Text(title)
                            Spacer()
                            if item.isChecked {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleIsChecked(for: item)
                        saveContext()
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("To Do List")
            // Adding the searchable modifier to the list
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search Items")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Add New Item", isPresented: $showAddAlert){
                TextField("New Item", text: $newItemText)
                Button("Add", role: .confirm) {
                    if !newItemText.isEmpty {
                        addItem(text: newItemText)
                        newItemText = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    newItemText = ""
                }
            } message: {
                Text("Please enter the new Item")
            }
        }
    }
    
    private func addItem(text: String){
        let newItem = Item(context: viewContext)
        newItem.timestamp = Date()
        newItem.id = UUID()
        newItem.string = text
        newItem.isChecked = false
        
        saveContext()
        newItemText = ""
    }
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error : \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(at offSets: IndexSet) {
        withAnimation {
//            offSets.map {pendingItems[$0]}.forEach(viewContext.delete)
//            saveContext()
            
            // Get the actual Item objects to delete from the filtered list
            let itemsToDelete = offSets.map { filteredPendingItems[$0] }
            
            // Loop through the items you just identified
            for item in itemsToDelete {
                viewContext.delete(item)
            }
            
            saveContext()
        }
        /*
         The Instruction (.onDelete): You give your assistant a standing order: "Whenever I swipe a file to the 'delete' pile, I want you to perform the deleteItems procedure." You are not telling them which file to delete yet, just what procedure to follow when a deletion happens.
         
         The Action (User Swipes): You swipe on the 3rd file in the stack. The system automatically generates a note that says "Row 3 needs to be deleted." This note is the IndexSet (or offSets in your code).
         
         Calling the Function: The system sees your standing order (.onDelete) and calls your assistant. It says, "The boss wants you to run the deleteItems procedure," and it hands the assistant the note that says "Row 3." The system automatically provides this note as the input for the procedure.
         
         The Procedure (deleteItems function): Your assistant (deleteItems) takes the note (offSets).
         offSets.map {pendingItems[$0]}: The assistant reads the note ("Row 3"), goes to the main stack of files (pendingItems), and pulls out the actual file from the 3rd position. They are mapping the row number to the actual file object.
         .forEach(viewContext.delete): The assistant then takes that file they just pulled out and puts it into the shredder (viewContext.delete). If the note had multiple row numbers, they would do this for each one.
         */
    }
    
    private func toggleIsChecked(for item: Item){
        withAnimation {
            item.isChecked.toggle()
            saveContext()
        }
    }

    //MARK: Role of OffSets
    /*
     // 1. This is your main list of data, like `pendingItems`.
     //    Let's use simple strings for this example.
     var chores = ["Wash dishes", "Take out trash", "Walk the dog", "Buy groceries", "Do laundry"]

     // 2. The user swipes to delete the 2nd and 5th items.
     //    SwiftUI gives you an `IndexSet` containing the indices [1, 4].
     let offSets: IndexSet = [1, 4]

     // 3. This is the `.map` operation.
     //    It iterates through `offSets` ([1, 4]).
     //    For each index, it looks up the item in the `chores` array.
     //    The result is a NEW array containing the actual items to be deleted.
     let itemsToDelete = offSets.map { index in
         return chores[index]
     }
     // After this line, `itemsToDelete` is now: ["Take out trash", "Do laundry"]

     // 4. This is the `.forEach` operation.
     //    It iterates through the `itemsToDelete` array.
     //    For each item, it calls a function (here, we'll just print it).
     //    In your code, this is where `viewContext.delete` is called for each item.
     itemsToDelete.forEach { item in
         print("Deleting: \(item)")
     }

     // Console Output:
     // Deleting: Take out trash
     // Deleting: Do laundry
     */
    
    
}

#Preview {
    ToDoListView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
