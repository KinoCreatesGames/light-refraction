package ext;

function getByFn<T>(arr:Array<T>, fn:T -> Bool):T {
  var result = arr.filter(fn);
  if (result != null) {
    return result[0];
  } else {
    return null;
  }
}

/**
 * Returns the first element of an array.
 * @param arr 
 * @return T
 */
function first<T>(arr:Array<T>):T {
  return arr[0];
}

/**
 * Returns the last element of an array.
 * @param arr 
 * @return T
 */
function last<T>(arr:Array<T>):T {
  return arr[arr.length - 1];
}