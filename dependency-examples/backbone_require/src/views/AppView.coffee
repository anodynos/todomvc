define ["jquery", "underscore", "backbone", "views/TodoView", "text!../../templates/stats.html", "common"],
($, _, Backbone, TodoView, statsTemplate, Common) ->

	class AppView extends Backbone.View
	#			constructor : (Todos = new TodosCollection) ->
		constructor : (@todos) ->
			console.log("new AppView")
			super

		# Instead of generating a new element, bind to the existing skeleton of
		# the App already present in the HTML.
		el : "#todoapp"

		# Compile our stats template
		template : _.template(statsTemplate)

		# Delegated events for creating new items, and clearing completed ones.
		events :
			"keypress #new-todo" : "createOnEnter"
			"click #clear-completed" : "clearCompleted"
			"click #toggle-all" : "toggleAllComplete"

		# At initialization we bind to the relevant events on the `Todos`
		# collection, when items are added or changed. Kick things off by
		# loading any preexisting todos that might be saved in *localStorage*.
		initialize : ->
			@input = @$("#new-todo")
			@allCheckbox = @$("#toggle-all")[0]
			@$footer = @$("#footer")
			@$main = @$("#main")

			# cache of the todo views
			# so that only one is created for each model
			@todoViewsCache = {}

			@todos.on "add", @addOne
			@todos.on "reset", @addAll
			@todos.on "change:completed", @filterOne
			@todos.on "filter", @filterAll
			@todos.on "all", @render
			@todos.fetch()


		# Re-rendering the App just means refreshing the statistics -- the rest
		# of the app doesn't change.
		render : =>
			completedCount = @todos.completed().length
			remainingCount = @todos.remaining().length
			if @todos.length
				@$main.show()
				@$footer.show()
				@$footer.html @template(
					completed : completedCount
					remaining : remainingCount
				)
				@$("#filters li a").removeClass("selected").filter("[href=\"#/" + (Common.TodoFilter or "") + "\"]").addClass "selected"
			else
				@$main.hide()
				@$footer.hide()
			@allCheckbox.checked = not remainingCount


		# Add a single todo item to the list by creating or cache-retrieving a view for it, and
		# appending its element to the `<ul>`.
		addOne : (todo) =>
			view = new TodoView(model : todo)
			$("#todo-list").append view.render().el


		# Add all items in the **Todos** collection at once.
		addAll : =>
			console.log "addAll"
			@$("#todo-list").html ""
			@todos.each @addOne, this

		filterOne : (todo) ->
			todo.trigger "visible"

		filterAll : =>
			@todos.each @filterOne, this

		# Generate the attributes for a new Todo item.
		newAttributes : ->
			title : @input.val().trim()
			order : @todos.nextOrder()
			completed : false
			rating : 0

		# If you hit return in the main input field, create new **Todo** model,
		# persisting it to *localStorage*.
		createOnEnter: (e) ->
			return  if e.which isnt Common.ENTER_KEY or not @input.val().trim()
			@todos.create @newAttributes()
			@input.val ""

		# Clear all completed todo items, destroying their models.
		clearCompleted : ->
			_.each @todos.completed(), (todo) ->
				todo.destroy()
			false

		toggleAllComplete : ->
			completed = @allCheckbox.checked
			@todos.each (todo) ->
				todo.save completed : completed

