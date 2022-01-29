package macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using haxe.macro.MacroStringTools;

/**
 * Allows for piping in the reasonML style.
 * @param exprs 
 */
macro function thread(exprs:Array<Expr>) {
  var exprs = [for (expr in exprs) macro var _ = $expr];
  exprs.push(macro _);
  return macro $b{exprs};
}
#end