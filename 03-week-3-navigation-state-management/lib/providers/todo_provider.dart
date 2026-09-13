import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  final String title;
  final bool done;

  Todo(this.title, {this.done = false});

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  void add(String title) => state = [...state, Todo(title)];

  void toggle(int index) {
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  void remove(int index) => state = [...state]..removeAt(index);
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

final activeTodosProvider = Provider<List<Todo>>((ref) {
  final allTodos = ref.watch(todoListProvider);
  return allTodos.where((todo) => !todo.done).toList();
});
