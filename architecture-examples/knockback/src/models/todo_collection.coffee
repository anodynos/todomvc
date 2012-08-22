class window.TodoCollection extends Backbone.Collection
	localStorage: new Store('todos-knockback') # Save all of the todos under the `"todos-knockback"` namespace.
	model: Todo

	completedCount: ->
		@models.reduce(((prev,cur) ->
			return prev + if cur.completed() then 1 else 0), 0)

	remainingCount: =>
		return @models.length - @completedCount()

	completeAll: (completed) ->
		@each (todo) -> todo.completed(completed)
		@

	destroyCompleted: ->
		completed_tasks = @filter((todo) ->
			return todo.completed())

		_.each(completed_tasks, (t) -> t.destroy())
		@

	comparator: (todo) ->
		(todo.get 'title').length