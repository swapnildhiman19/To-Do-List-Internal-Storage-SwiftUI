//
//  CategoryView.swift
//  To-Do-List-Internal-Storage-SwiftUI
//
//  Created by EasyAiWithSwapnil on 12/09/25.
//
import SwiftUI
import CoreData

struct CategoryView : View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.timestamp, ascending: true)])
    private var pendingCategoryItems : FetchedResults<Category>
    
    @State var searchText: String = ""
    @State var showAddAlert : Bool = false
    
    @State var newPendingCategoryText : String = ""
    
    @State var categorySelected : Category?
    
    var filteredPendingCategoryItems : [Category] {
        if searchText.isEmpty {
            return pendingCategoryItems.map { $0 }
        } else {
            return pendingCategoryItems.filter {
                $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    
    var body : some View {
        NavigationStack {
            List {
                ForEach(filteredPendingCategoryItems){ item in
                    HStack {
                        if let cellInfo = item.name {
                            Text(cellInfo)
                            Spacer()
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Here we need to call the ToDoList View for this Category Cell
                        // print("Cell with \(item.name ?? "NIL") has been tapped")
                        self.categorySelected = item
                    }
                }
                // .onDelete(perform: deleteCategoryItems) //TODO: Deleting a Category should delete all the items present inside it
                .onDelete(perform: deleteCategoryItems)
            }
            .navigationDestination(isPresented: .init(
                get: {
                    self.categorySelected != nil
                },
                set: { isPresented in
                    // When the user navigates back, isPresented becomes false
                    if !isPresented{
                        self.categorySelected = nil
                    }
                }
            ),
            destination: {
                if let categorySelected = self.categorySelected {
                    ToDoListView(parentCategory: categorySelected)
                }
            })
            .navigationTitle("Category To Do List")
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search To Do Category")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Add New To Do Category", isPresented: $showAddAlert) {
                TextField("New Category", text: $newPendingCategoryText)
                Button("Add", role: .confirm) {
                    if !newPendingCategoryText.isEmpty {
                        addCategory(text: newPendingCategoryText)
                        newPendingCategoryText = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    newPendingCategoryText = ""
                }
            } message: {
                //                Text("Please Enter New Category")
            }
        }
    }
    
    private func addCategory(text: String){
        let newCategory = Category(context: viewContext)
        newCategory.name = text
        newCategory.timestamp = Date()
        saveContext()
        newPendingCategoryText = ""
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
    
    private func deleteCategoryItems(at offSet: IndexSet) {
        /*
         Delete Rule Relationship is set to Cascade meaning deletion of Category will delete all the items present in it.
         */
        let actualCategoriesToDelete = offSet.map { filteredPendingCategoryItems[$0] }
        
        for category in actualCategoriesToDelete {
            viewContext.delete(category)
        }
        
        saveContext()
    }
}

#Preview {
    CategoryView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
