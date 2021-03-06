%% Module responsible for local invocation of macros and functions.
-module(elixir_def_local).
-export([
  macro_for/3,
  function_for/3,
  format_error/1,
  check_unused_local_macros/3
]).
-include("elixir.hrl").

%% Reading

macro_for(_Tuple, _All, #elixir_scope{module=[]}) -> false;

macro_for(Tuple, All, #elixir_scope{module=Module}) ->
  case ets:lookup(elixir_def:table(Module), Tuple) of
    [{Tuple, Line, _, Kind, _, Clauses}] when Kind == defmacro; All, Kind == defmacrop ->
      RewrittenClauses = [rewrite_clause(Clause, Module) || Clause <- Clauses],
      Fun = { 'fun', Line, {clauses, lists:reverse(RewrittenClauses)} },
      { value, Result, _Binding } = erl_eval:exprs([Fun], []),
      Result;
    _ -> false
  end.

function_for(Module, Name, Arity) ->
  Tuple = { Name, Arity },
  case ets:lookup(elixir_def:table(Module), Tuple) of
    [{Tuple, Line, _, _, _, Clauses}] ->
      % elixir_def_local:record(Line, Tuple, false, Module),
      RewrittenClauses = [rewrite_clause(Clause, Module) || Clause <- Clauses],
      Fun = { 'fun', Line, {clauses, lists:reverse(RewrittenClauses)} },
      { value, Result, _Binding } = erl_eval:exprs([Fun], []),
      Result;
    _ ->
      [_|T] = erlang:get_stacktrace(),
      erlang:raise(error, undef, [{Module,Name,Arity,[]}|T])
  end.

%% Helpers
%% TODO: Consider caching functions in a table for performance.

rewrite_clause({ call, Line, { atom, Line, RawName }, Args }, Module) ->
  Remote = { remote, Line,
    { atom, Line, ?MODULE },
    { atom, Line, function_for }
  },
  Arity   = { integer, Line, length(Args) },
  Name    = { atom, Line, rewrite_name(atom_to_list(RawName), RawName) },
  FunCall = { call, Line, Remote, [{ atom, Line, Module }, Name, Arity] },
  { call, Line, FunCall, Args };

rewrite_clause(Tuple, Module) when is_tuple(Tuple) ->
  list_to_tuple(rewrite_clause(tuple_to_list(Tuple), Module));

rewrite_clause(List, Module) when is_list(List) ->
  [rewrite_clause(Item, Module) || Item <- List];

rewrite_clause(Else, _) -> Else.

rewrite_name("MACRO-" ++ Rest, _) -> list_to_atom(Rest);
rewrite_name(_, Name) -> Name.

%% Error handling

check_unused_local_macros(Filename, Recorded, PMacros) ->
  [elixir_errors:handle_file_warning(Filename,
    { Line, ?MODULE, { unused_macro, Fun } }) || { Fun, Line } <- PMacros, not lists:member(Fun, Recorded)].

format_error({unused_macro,{Name, Arity}}) ->
  io_lib:format("macro ~s/~B is unused", [Name, Arity]).