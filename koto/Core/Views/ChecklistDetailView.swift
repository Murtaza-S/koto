//
//  ChecklistDetailView.swift
//  koto
//
//  Created by ChatGPT on 26/11/25.
//

import SwiftUI
import SwiftData

struct ChecklistDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var list: ChecklistList
    @State private var newItemText: String = ""

    private var service: ChecklistService {
        ChecklistService(modelContext: modelContext)
    }

    private var todoItems: [ChecklistItem] {
        list.activeItems
    }

    private var completedItems: [ChecklistItem] {
        list.completedItems
    }

    var body: some View {
        List {
            Section("Todo") {
                if todoItems.isEmpty {
                    ContentUnavailableView(
                        "All clear!",
                        systemImage: "checkmark.circle",
                        description: Text("Add new items to keep track of tasks.")
                    )
                } else {
                    ForEach(todoItems) { item in
                        HStack(spacing: 12) {
                            Button {
                                toggleCompletion(item)
                            } label: {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                                    .imageScale(.large)
                                    .accessibilityLabel("Mark as done")
                            }

                            Text(item.text)
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                delete(items: [item])
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { offsets in
                        let targets = offsets.map { todoItems[$0] }
                        delete(items: targets)
                    }
                }
            }

            if !completedItems.isEmpty {
                Section("Completed") {
                    ForEach(completedItems) { item in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(item.text)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                toggleCompletion(item)
                            } label: {
                                Label("Move to Todo", systemImage: "arrow.uturn.backward.circle")
                            }

                            Button(role: .destructive) {
                                delete(items: [item])
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { offsets in
                        let targets = offsets.map { completedItems[$0] }
                        delete(items: targets)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(list.title)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack(spacing: 12) {
                    TextField("Add checklist item", text: $newItemText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addItem)
                        .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        withAnimation {
            service.addItem(text: trimmed, to: list)
            newItemText = ""
        }
    }

    private func toggleCompletion(_ item: ChecklistItem) {
        withAnimation {
            service.toggleCompletion(item)
        }
    }

    private func delete(items: [ChecklistItem]) {
        withAnimation {
            service.delete(items)
        }
    }
}

