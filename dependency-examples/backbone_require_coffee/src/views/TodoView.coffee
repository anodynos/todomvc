define ["jquery", "wijrating", "underscore", "backbone", "text!../../templates/todos.html", "common"],
	($, wijrating, _, Backbone, todosTemplate, Common) ->
		class TodoView extends Backbone.View
			constructor: ->
				console.log("new TodoView")
				super

			tagName: "li"

			template: _.template(todosTemplate)

			# The DOM events specific to an item.
			events:
				"click .toggle": "togglecompleted"
				"dblclick label": "edit"
				"click .destroy": "clear"
				"keypress .edit": "updateOnEnter"
				"blur .edit": "close"
				"wijratingrated .rating": "rated"

			# The TodoView listens for changes to its model, re-rendering. Since there's
			# a one-to-one correspondence between a **Todo** and a **TodoView** in this
			# app, we set a direct reference on the model for convenience.
			initialize: ->
				@model.on "change", @render
				@model.on "destroy", @remove, @
				@model.on "visible", @toggleVisible

			# Re-render the titles of the todo item.
			render: =>
#				console.log "TodoView.render"
#				console.log @model
				@$el.html @template(@model.toJSON())
				@$el.toggleClass "completed", @model.get("completed")
				@toggleVisible()

				@rat = @$('.rating').wijrating("widget")
				@rat.wijrating
					value: @model.get("rating"),
					count:15,
					max: 10
					totalValue: 10

				@rat.value = (val) ->
					if val then @wijrating("option", "value", val) else @wijrating("option", "value")

				@input = @$(".edit")
				@

			toggleVisible: =>
				@$el.toggleClass "hidden", @isHidden()

			isHidden: ->
				isCompleted = @model.get("completed")
				(not isCompleted and Common.TodoFilter is "completed") or
				(isCompleted and Common.TodoFilter is "active")

			# Toggle the `"completed"` state of the model.
			togglecompleted: ->
				@model.toggle()

			rated: (e, args) ->
				@model.save rating: args.value

			# Switch this view into `"editing"` mode, displaying the input field.
			edit: =>
				@rat.value(1)
				@$el.addClass "editing"
				@input.focus()

			# Close the `"editing"` mode, saving changes to the todo.
			close: =>
				value = @input.val().trim()
				if value
					@model.save title: value
				else
					@clear()
				@$el.removeClass "editing"

			# If you hit `enter`, we're through editing the item.
			updateOnEnter: (e) ->
				@close()  if e.keyCode is Common.ENTER_KEY

			# Remove the item, destroy the model from *localStorage* and delete its view.
			clear: ->
				@model.destroy()
