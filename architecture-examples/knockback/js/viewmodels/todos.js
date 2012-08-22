// Generated by CoffeeScript 1.3.3
(function() {
  var TodoViewModel;

  TodoViewModel = function(model) {
    var _this = this;
    this.isEditing = ko.observable(false);
    this.isCompleted = kb.observable(model, {
      key: 'completed'
    });
    this.isVisible = ko.computed(function() {
      switch (app.viewmodels.settings.list_filter_mode()) {
        case 'active':
          return !_this.isCompleted();
        case 'completed':
        case 'done':
          return _this.isCompleted();
        default:
          return true;
      }
    });
    this.title = kb.observable(model, {
      key: 'title',
      write: function(title) {
        if ($.trim(title)) {
          model.save({
            title: $.trim(title)
          });
        } else {
          _.defer(function() {
            return model.destroy();
          });
        }
        return _this.isEditing(false);
      }
    }, this);
    this.onDestroyTodo = function() {
      return model.destroy();
    };
    this.onCheckEditBegin = function() {
      if (!_this.isEditing() && !_this.isCompleted()) {
        return _this.isEditing(true);
      }
    };
    this.onCheckEditEnd = function(view_model, event) {
      if ((event.keyCode === 13) || (event.type === 'blur')) {
        return $('.todo-input').blur()(_this.isEditing(false));
      }
    };
    return this;
  };

  window.TodosViewModel = function(todos) {
    var _this = this;
    this.todos = kb.collectionObservable(todos, {
      view_model: TodoViewModel
    });
    this.todos.collection().bind('change', function() {
      return _this.todos.valueHasMutated();
    });
    this.tasks_exist = ko.computed(function() {
      return _this.todos().length;
    });
    this.all_completed = ko.computed({
      read: function() {
        return !_this.todos.collection().remainingCount();
      },
      write: function(completed) {
        return _this.todos.collection().completeAll(completed);
      }
    });
    return this;
  };

}).call(this);
