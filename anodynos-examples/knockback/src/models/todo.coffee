class window.Todo extends Backbone.Model
	completed: (completed) ->
		if arguments.length == 0
			return !!@get('completed');
		@save({completed: if completed then new Date() else null});
