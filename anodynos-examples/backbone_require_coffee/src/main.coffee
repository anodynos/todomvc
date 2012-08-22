define ["underscore", "backbone", "views/AppView", "routers/TodoRouter", "collections/TodosCollection"],
(_, Backbone, AppView, Router, TodosCollection) ->

	todos = new TodosCollection

	# Initialize the application view
	new AppView todos

	# Initialize routing and start Backbone.history
	new Router todos

	Backbone.history.start()
	null


