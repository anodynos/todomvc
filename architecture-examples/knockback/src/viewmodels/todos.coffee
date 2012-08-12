TodoViewModel = (model) ->
	# Task UI state
	@isEditing = ko.observable(false)

	@isCompleted = kb.observable(model, {
		key: 'completed',
		read: (-> return model.completed()),
		write: ((completed) -> model.completed(completed)) }
		, @)

	@isVisible = ko.computed(=>
		switch app.viewmodels.settings.list_filter_mode()
			when 'active' then return not @completed()
			when 'completed', 'done' then return @completed()
			else return true
	)

	@title = kb.observable(model, {
		key: 'title'
		write: ((title) =>
			if $.trim(title)
				model.save(title: $.trim(title))
			else
				_.defer(->model.destroy())

			@editing(false);
			)
	}, @)

	@onDestroyTodo = => model.destroy()

	@onCheckEditBegin = =>
		if not @editing() and not @completed()
			@editing(true)

	@onCheckEditEnd = (view_model, event) =>
		if (event.keyCode == 13) or (event.type == 'blur')
			($('.todo-input').blur() @editing(false))
	@

window.TodosViewModel = (todos) ->
	@todos = kb.collectionObservable(todos, {view_model: TodoViewModel})

	@todos.collection().bind('change', => @todos.valueHasMutated())   # get notified of changes to any models

	@tasks_exist = ko.computed(=> @todos().length)

	@all_completed = ko.computed(
		read: => return not @todos.collection().remainingCount()
		write: (completed) => @todos.collection().completeAll(completed)
	)
	@
