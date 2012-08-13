define ["jquery", "backbone", "common"],
($, Backbone, Common) ->

	class TodoRouter extends Backbone.Router
		constructor : (@todos) ->
			super

		routes :
			"*filter" : "setFilter"

		setFilter : (param) =>

			# Set the current filter to be used
			Common.TodoFilter = param.trim() or ""

			# Trigger a collection 'filter' event, causing hiding/unhiding of todo view items
			@todos.trigger "filter"