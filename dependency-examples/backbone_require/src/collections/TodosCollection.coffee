define ["underscore", "backbone", "backbone.localstorage", "models/TodoModel"],
(_, Backbone, Store, Todo) ->

	class TodosCollection extends Backbone.Collection
		constructor : ->
			console.log("new TodosCollection")
			super

		# Reference to this collection's model.
		model : Todo

		# Save all of the todo items under the `"todos"` namespace.
		localStorage : new Store("todos-backbone-require")

		# Filter down the list of all todo items that are finished.
		completed : ->
			@filter (todo) ->
				todo.get "completed"

		# Filter down the list to only todo items that are still not finished.
		remaining : ->
			@without.apply @, @completed()

		# We keep the Todos in sequential order, despite being saved by unordered
		# GUID in the database. This generates the next order number for new items.
		nextOrder : ->
			if not @length then return 1
			@last().get("order") + 1

		# Todos are sorted by their original insertion order.
		comparator : (todo) ->
			todo.get "order"
