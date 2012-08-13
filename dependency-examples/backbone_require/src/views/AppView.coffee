define ["jquery", "underscore", "backbone", "collections/TodosCollection", "views/TodoView", "text!../../templates/stats.html", "common"],
	($, _, Backbone, Todos, TodoView, statsTemplate, Common) ->
		class AppView extends Backbone.View
		#			constructor : (Todos = new TodosCollection) ->
			constructor : ->
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

				Todos.on "add", @addOne
				Todos.on "reset", @addAll
				Todos.on "change:completed", @filterOne
				Todos.on "filter", @filterAll
				Todos.on "all", @render
				Todos.fetch()


			# Re-rendering the App just means refreshing the statistics -- the rest
			# of the app doesn't change.
			render : =>
				completedCount = Todos.completed().length
				remainingCount = Todos.remaining().length
				if Todos.length
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
				Todos.each @addOne, this

			filterOne : (todo) ->
				todo.trigger "visible"

			filterAll : =>
				Todos.each @filterOne, this

			# Generate the attributes for a new Todo item.
			newAttributes : ->
				title : @input.val().trim()
				order : Todos.nextOrder()
				completed : false
				rating : 0

			# If you hit return in the main input field, create new **Todo** model,
			# persisting it to *localStorage*.
			createOnEnter: (e) ->
				return  if e.which isnt Common.ENTER_KEY or not @input.val().trim()
				Todos.create @newAttributes()
				@input.val ""

			# Clear all completed todo items, destroying their models.
			clearCompleted : ->
				_.each Todos.completed(), (todo) ->
					todo.destroy()
				false

			toggleAllComplete : ->
				completed = @allCheckbox.checked
				Todos.each (todo) ->
					todo.save completed : completed

