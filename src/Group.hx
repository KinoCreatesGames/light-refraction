/**
 * Groups elements together.
 * Useful convenience purposes.
 */
@:forward()
abstract Group<T>(Array<T>) from Array<T> {
  public inline function new(?elements:Array<T>) {
    this = [];
    if (elements != null) {
      for (element in elements) {
        add(element);
      }
    }
  }

  public inline function maxCount() {
    return this.length;
  }

  public inline function add(el:T) {
    this.push(el);
  }

  public inline function remove(el:T) {
    var result = this.remove(el);
    return result;
  }

  public inline function get(index:Int) {
    return this[index];
  }

  /**
   * Removes all elements from the group
   */
  public inline function clear() {
    this.resize(0);
  }
}