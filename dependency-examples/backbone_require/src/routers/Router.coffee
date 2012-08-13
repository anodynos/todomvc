define ["jquery", "backbone", "collections/TodosCollection", "common"],
($, Backbone, Todos, Common) ->
	Router = Backbone.Router.extend(

		routes :
			"*filter" : "setFilter"

		setFilter : (param) =>

			# Set the current filter to be used
			Common.TodoFilter = param.trim() or ""

			# Trigger a collection 'filter' event, causing hiding/unhiding of todo view items
			Todos.trigger "filter"
	)
#	class TodoRouter extends Backbone.Router
#
#		routes :
#			"*filter" : "setFilter"
#
#		setFilter : (param) =>
#
#			# Set the current filter to be used
#			Common.TodoFilter = param.trim() or ""
#
#			# Trigger a collection 'filter' event, causing hiding/unhiding of todo view items
#			Todos.trigger "filter"