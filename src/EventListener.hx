/**
 * Custom Utility class for creating
 * events within the game and  separating 
 * calls and references from the objects
 * that may require that information.
 */
class EventListener<T> {
  /**
   * Handlers that are called when the event is executed within the listener.
   */
  public var handlers:Array<Handler<T>>;

  /**
   * List of events that are within each handler
   */
  public var events:Array<String>;

  public var eventMap:Map<String, Array<Handler<T>>>;
  public var _uid:Int;
  public var uid(get, set):Int;

  public inline function set_uid(value:Int) {
    _uid = value;
    return value;
  }

  public inline function get_uid() {
    return _uid++;
  }

  public static function create() {
    return new EventListener();
  }

  public function new() {
    handlers = [];
    events = [];
    eventMap = [];
    uid = 0;
  }

  public function listEvents() {
    return events;
  }

  public function listHandlers() {
    return handlers;
  }

  public function addListener(event:String, fn:T -> Void, priority = -1) {
    var newHandler = {
      event: event,
      fn: fn,
      priority: priority,
      uid: uid
    };
    handlers.push(newHandler);
    if (!events.contains(event)) {
      events.push(event);
    }
    var mapHandlers = eventMap.get(event);
    if (mapHandlers != null) {
      mapHandlers.push(newHandler);
      mapHandlers.sort((handleA, handleB) -> handleA.priority
        - handleB.priority);
    } else {
      eventMap.set(event, [newHandler]);
    }
  }

  public function removeListener() {}

  public function clear() {
    handlers.resize(0);
    events.resize(0);
    eventMap.clear();
  }

  public function emit(event:String, el:T) {
    var mapHandlers = eventMap.get(event);
    if (mapHandlers != null) {
      for (handler in mapHandlers) {
        handler.fn(el);
      }
    }
  }
}

typedef Handler<T> = {
  priority:Int,
  fn:T -> Void,
  event:String,
  uid:Int
}