ENTER_KEY = 13

window.HeaderViewModel = (todos) ->
	@title = ko.observable('');

	@onAddTodo = (view_model, event) =>
		if not $.trim(@title()) or (event.keyCode != ENTER_KEY)
			return true;

		# Create task and reset UI
		todos.create({title: $.trim(@title())})
		@title('')
	@
