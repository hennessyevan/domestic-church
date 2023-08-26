//
//  ContentView.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import CoreData
import SwiftUI

struct GameplanView: View {
	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Gameplan.createdAt, ascending: true)],
		animation: .default)
	private var gameplans: FetchedResults<Gameplan>

	var body: some View {
		NavigationView {
			ScrollView {
				VStack {
					ForEach(gameplans) { gameplan in
						GameplanCard(gameplan: gameplan)
					}
					.onDelete(perform: deleteItems)
				}
				.padding(.all)
				.navigationTitle("Gameplan")
				.toolbar {
					ToolbarItem(placement: .automatic) {
						Button(action:addItem) {
							Image(systemName: "plus")
						}
					}
				}
			}
			.frame(minWidth: 0, maxWidth: .infinity)
#if os(iOS)
			.background(Color.systemGroupedBackground)
#endif
		}
	}

	private func addItem() {
		withAnimation {
			let newItem = Gameplan(context: viewContext)
			newItem.createdAt = Date()
			newItem.wrappedActivityType = .scripture

			do {
				try viewContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}

	private func deleteItems(offsets: IndexSet) {
		withAnimation {
			offsets.map { gameplans[$0] }.forEach(viewContext.delete)

			do {
				try viewContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
}

private let itemFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .full
	formatter.timeStyle = .none
	return formatter
}()

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		GameplanView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
	}
}
