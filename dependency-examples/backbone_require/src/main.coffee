define ["underscore", "backbone", "views/AppView", "routers/Router", "collections/TodosCollection"],
(_, Backbone, AppView, Router, TodosCollection) ->

	#todos = null; #new TodosCollection

	# Initialize the application view
	new AppView

	# Initialize routing and start Backbone.history
	new Router

	Backbone.history.start()
	null


