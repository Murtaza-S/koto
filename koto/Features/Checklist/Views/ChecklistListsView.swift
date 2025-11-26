//
//  ContentView.swift
//  koto
//
//  Created by Sahiba on 25/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<ChecklistList> { $0.isArchived == false },
        sort: \ChecklistList.updatedAt,
        order: .reverse,
        animation: .default
    ) private var checklists: [ChecklistList]

    @Query(
        filter: #Predicate<ChecklistItem> { $0.isCompleted == true },
        sort: \ChecklistItem.updatedAt,
        order: .reverse,
        animation: .default
    ) private var completedItems: [ChecklistItem]

    @State private var newListTitle: String = ""

    private var service: ChecklistService {
        ChecklistService(modelContext: modelContext)
    }

    var body: some View {
        TabView {
            NavigationStack {
                VStack(spacing: 16) {
                    addListField
                    checklistList
                }
                .padding()
                .navigationTitle("Checklists")
            }
            .tabItem {
                Label("Todo", systemImage: "list.bullet.circle")
            }

            NavigationStack {
                completedItemsList
                    .navigationTitle("Accomplished")
            }
            .tabItem {
                Label("Accomplished", systemImage: "checkmark.circle")
            }
        }
    }

    private var addListField: some View {
        HStack(spacing: 12) {
            TextField("Create a checklist", text: $newListTitle, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .onSubmit(addList)

            Button(action: addList) {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.kotoAccent)
                    )
                    .accessibilityLabel("Add checklist")
            }
            .disabled(newListTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(.plain)
        }
    }

    private var checklistList: some View {
        List {
            ForEach(checklists) { list in
                NavigationLink {
                    ChecklistDetailView(list: list)
                } label: {
                    ChecklistRow(list: list)
                }
            }
            .onDelete { offsets in
                let targets = offsets.map { checklists[$0] }
                deleteLists(targets)
            }
        }
        .listStyle(.plain)
        .overlay {
            if checklists.isEmpty {
                ContentUnavailableView(
                    "No checklists yet",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Create your first checklist to get started.")
                )
            }
        }
    }

    private var completedItemsList: some View {
        List {
            ForEach(completedItems) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.text)
                        .foregroundStyle(.secondary)
                    if let list = item.list {
                        Text(list.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        toggleCompletion(item)
                    } label: {
                        Label("Move to Todo", systemImage: "arrow.uturn.backward.circle")
                    }

                    Button(role: .destructive) {
                        deleteItems([item])
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onDelete { offsets in
                let targets = offsets.map { completedItems[$0] }
                deleteItems(targets)
            }
        }
        .listStyle(.plain)
        .overlay {
            if completedItems.isEmpty {
                ContentUnavailableView(
                    "No completed items",
                    systemImage: "tray",
                    description: Text("Completed checklist items will appear here.")
                )
            }
        }
    }

    private func addList() {
        let trimmed = newListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        withAnimation {
            service.createList(title: trimmed)
            newListTitle = ""
        }
    }

    private func deleteLists(_ lists: [ChecklistList]) {
        withAnimation {
            service.deleteLists(lists)
        }
    }

    private func toggleCompletion(_ item: ChecklistItem) {
        withAnimation {
            service.toggleCompletion(item)
        }
    }

    private func deleteItems(_ items: [ChecklistItem]) {
        withAnimation {
            service.deleteItems(items)
        }
    }
}

private struct ChecklistRow: View {
    @Bindable var list: ChecklistList

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(list.title)
                    .font(.headline)
                Text("\(list.activeItems.count) remaining • \(list.completedItems.count) done")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

private extension Color {
    static let kotoAccent = Color(red: 1.0, green: 189/255, blue: 74/255)
}

#Preview {
    ContentView()
        .modelContainer(for: [ChecklistList.self, ChecklistItem.self], inMemory: true)
}
