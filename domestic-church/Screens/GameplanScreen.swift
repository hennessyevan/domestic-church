//
//  ContentView.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftData
import SwiftUI
import SwipeActions
import SystemColors

@Observable
class GameplanScreenViewModel {
	var expandedId: PersistentIdentifier?
}

struct GameplanView: View {
	@Environment(\.modelContext) private var modelContext

	@Query(sort: \Gameplan.createdAt, order: .forward, animation: .default) private var gameplans: [Gameplan]

	@State private var isNewItemDialogShown = false
	
	@State var viewModel = GameplanScreenViewModel()

	var body: some View {
		NavigationView {
			ScrollView {
				if gameplans.isEmpty {
					EmptyView()
				} else {
					VStack(alignment: .leading) {
						ForEach(gameplans) { gameplan in
							GameplanRow(gameplan: gameplan)
						}
					}
					.frame(minWidth: 0, maxWidth: .infinity)
					.padding()
				}
			}
			.navigationTitle("Gameplan")
			.toolbar {
				ToolbarItem(placement: .automatic) {
					Button(action: { isNewItemDialogShown = true }) {
						Image(systemName: "plus")
					}
				}
			}
			.confirmationDialog("What type?", isPresented: $isNewItemDialogShown) {
				ForEach(ActivityType.allCases) { activityType in
					Button(activityType.rawValue.localized) { self.addGameplan(with: activityType) }
				}
			}
			.background(Color.systemGroupedBackground)
		}.environment(viewModel)
	}

	struct EmptyView: View {
		var body: some View {
			Text("Press + to add a gameplan")
				.font(.headline)
				.foregroundStyle(.secondary)
				.frame(minWidth: 0, maxWidth: .infinity)
				.padding()
		}
	}

	struct GameplanRow: View {
		var gameplan: Gameplan

		@State private var confirmingDelete = false
		@State private var isLoaded = false

		@State var swipeState: SwipeState = .untouched

		var body: some View {
			GameplanCard(gameplan: gameplan)
				.id(gameplan.id)
				.addSwipeAction(menu: .swiped, edge: .trailing, state: $swipeState) {
					Leading { SwiftUI.EmptyView() }
					Trailing {
						Button {
							confirmingDelete = true
						} label: {
							Image(systemName: "trash")
								.foregroundColor(.white)
						}
						.frame(width: 75, alignment: .center)
						.frame(maxHeight: .infinity)
						.cornerRadius(12)
						.contentShape(Rectangle())
						.background(Color.red)
					}.opacity(isLoaded ? 1 : 0)
				}
				.background(Color.red.opacity(isLoaded ? 1 : 0))
				.cornerRadius(12)
				.confirmationDialog(
					"Delete Gameplan",
					isPresented: $confirmingDelete,
					actions: {
						Button(
							role: .destructive,
							action: { deleteGameplan(gameplan: gameplan) },
							label: { Text("Delete") }
						)
						Button("Cancel", role: .cancel) {
							swipeState = .swiped(UUID())
						}
					},
					message: {
						Text("Are you sure you want to delete this gameplan?")
					}
				)
				.onAppear {
					// Give the card time to fade in otherwise the red background shows
					DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) {
						isLoaded = true
					}
				}
		}

		private func deleteGameplan(gameplan: Gameplan) {
			gameplan.modelContext?.delete(gameplan)
		}
	}

	private func addGameplan(with activityType: ActivityType) {
		let newGameplan = Gameplan(activityType: activityType)
		modelContext.insert(newGameplan)
	}
}

private let itemFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .full
	formatter.timeStyle = .none
	return formatter
}()

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Gameplan.self, configurations: config)

	let gameplans = [Gameplan(activityType: .personalPrayer), Gameplan(activityType: .scripture)].forEach({
		container.mainContext.insert($0)
	})

	return GameplanView().modelContainer(container)
}
