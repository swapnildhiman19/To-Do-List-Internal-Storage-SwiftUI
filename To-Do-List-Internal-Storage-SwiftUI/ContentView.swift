//
//  ContentView.swift
//  To-Do-List-Internal-Storage-SwiftUI
//
//  Created by Swapnil Dhiman on 24/07/25.
//

import SwiftUI

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
            List($pendignItems) { $item in
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
}

#Preview {
    ContentView()
}
