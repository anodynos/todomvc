// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["underscore", "backbone", "backbone.localstorage", "models/TodoModel"], function(_, Backbone, Store, Todo) {
    var TodosCollection;
    TodosCollection = (function(_super) {

      __extends(TodosCollection, _super);

      function TodosCollection() {
        console.log("new TodosCollection");
        TodosCollection.__super__.constructor.apply(this, arguments);
      }

      TodosCollection.prototype.model = Todo;

      TodosCollection.prototype.localStorage = new Store("todos-backbone-require");

      TodosCollection.prototype.completed = function() {
        return this.filter(function(todo) {
          return todo.get("completed");
        });
      };

      TodosCollection.prototype.remaining = function() {
        return this.without.apply(this, this.completed());
      };

      TodosCollection.prototype.nextOrder = function() {
        if (!this.length) {
          return 1;
        }
        return this.last().get("order") + 1;
      };

      TodosCollection.prototype.comparator = function(todo) {
        return todo.get("order");
      };

      return TodosCollection;

    })(Backbone.Collection);
    return new TodosCollection();
  });

}).call(this);
