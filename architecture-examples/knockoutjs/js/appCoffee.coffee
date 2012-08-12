#global ko, crossroads
(->
	"use strict"
	ENTER_KEY = 13

	# a custom binding to handle the enter key (could go in a separate library)
	ko.bindingHandlers.enterKey = init: (element, valueAccessor, allBindingsAccessor, data) ->

		# wrap the handler with a check for the enter key
		wrappedHandler = (data, event) ->
			if event.keyCode is ENTER_KEY
				valueAccessor().call this, data, event
			null

		# create a valueAccessor with the options that we would want to pass to the event binding
		newValueAccessor = ->
			keyup: wrappedHandler

		# call the real event binding's init function
		ko.bindingHandlers.event.init element, newValueAccessor, allBindingsAccessor, data
		null

	# wrapper to hasfocus that also selects text and applies focus async
	ko.bindingHandlers.selectAndFocus =
		init: (element, valueAccessor, allBindingsAccessor) ->
			ko.bindingHandlers.hasfocus.init element, valueAccessor, allBindingsAccessor
			ko.utils.registerEventHandler element, "focus", ->
				element.focus()
				element.select()



		update: (element, valueAccessor) ->
			ko.utils.unwrapObservable valueAccessor() # for dependency
			# ensure that element is visible before trying to focus
			setTimeout (->
				ko.bindingHandlers.hasfocus.update element, valueAccessor
			), 0


	# represent a single todo item
	Todo = (title, completed) ->
		@title = ko.observable(title)
		@completed = ko.observable(completed)
		@editing = ko.observable(false)
		null

	# our main view model
	ViewModel = (todos) ->
		self = this

		# map array of passed in todos to an observableArray of Todo objects
		self.todos = ko.observableArray(ko.utils.arrayMap(todos, (todo) ->
			new Todo(todo.title, todo.completed)
		))

		# store the new todo value being entered
		self.current = ko.observable()
		self.showMode = ko.observable("all")
		self.filteredTodos = ko.computed(->
			switch self.showMode()
				when "active"
					self.todos().filter (todo) ->
						not todo.completed()

				when "completed"
					self.todos().filter (todo) ->
						todo.completed()

				else
					self.todos()
		)

		# add a new todo, when enter key is pressed
		self.add = ->
			current = self.current().trim()
			if current
				self.todos.push new Todo(current)
				self.current ""


		# remove a single todo
		self.remove = (todo) ->
			self.todos.remove todo


		# remove all completed todos
		self.removeCompleted = ->
			self.todos.remove (todo) ->
				todo.completed()



		# edit an item
		self.editItem = (item) ->
			item.editing true


		# stop editing an item.  Remove the item, if it is now empty
		self.stopEditing = (item) ->
			item.editing false
			self.remove item  unless item.title().trim()


		# count of all completed todos
		self.completedCount = ko.computed(->
			ko.utils.arrayFilter(self.todos(), (todo) ->
				todo.completed()
			).length
		)

		# count of todos that are not complete
		self.remainingCount = ko.computed(->
			self.todos().length - self.completedCount()
		)

		# writeable computed observable to handle marking all complete/incomplete
		self.allCompleted = ko.computed(

			#always return true/false based on the done flag of all todos
			read: ->
				not self.remainingCount()


			# set all todos to the written value (true/false)
			write: (newValue) ->
				ko.utils.arrayForEach self.todos(), (todo) ->

					# set even if value is the same, as subscribers are not notified in that case
					todo.completed newValue

		)

		# helper function to keep expressions out of markup
		self.getLabel = (count) ->
			(if ko.utils.unwrapObservable(count) is 1 then "item" else "items")


		# internal computed observable that fires whenever anything changes in our todos

		# store a clean copy to local storage, which also creates a dependency on the observableArray and all observables in each item
		ko.computed(->
			localStorage.setItem "todos-knockout", ko.toJSON(self.todos)
		).extend throttle: 500 # save at most twice per second

		null


	# check local storage for todos
	todos = ko.utils.parseJson(localStorage.getItem("todos-knockout"))

	# bind a new instance of our view model to the page
	viewModel = new ViewModel(todos or [])
	ko.applyBindings viewModel

	#setup crossroads
	crossroads.addRoute "all", ->
		viewModel.showMode "all"

	crossroads.addRoute "active", ->
		viewModel.showMode "active"

	crossroads.addRoute "completed", ->
		viewModel.showMode "completed"

	window.onhashchange = ->
		crossroads.parse location.hash.replace("#", "")

	crossroads.parse location.hash.replace("#", "")
)()