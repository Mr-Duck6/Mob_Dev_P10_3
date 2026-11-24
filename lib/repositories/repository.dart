
abstract class Repository<T> {
  Future<T> insert(T item);

  Future<List<T>> getAll();

  Future<T?> getById(int id);

  Future<void> update(T item);

  Future<void> delete(int id);

  Future<void> deleteAll();

  Future<int> count();
}
