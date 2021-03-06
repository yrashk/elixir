% Grammar for the Elixir language done with yecc
% Copyright (C) 2011 Jose Valim

Nonterminals
  grammar expr_list
  expr block_expr fn_expr bracket_expr call_expr max_expr
  base_expr matched_expr matched_op_expr unmatched_expr op_expr
  comma_separator
  add_op mult_op unary_op addadd_op multmult_op bin_concat_op
  match_op arrow_op default_op when_op pipe_op in_op stab_op
  andand_op oror_op and_op or_op comp_expr_op
  open_paren close_paren
  open_bracket close_bracket
  open_curly close_curly
  open_bit close_bit
  comma_expr matched_comma_expr call_args_comma_expr
  call_args call_args_parens call_args_no_parens
  stab_expr stab_expr_list
  kw_eol kw_expr kw_comma kw_base
  matched_kw_expr matched_kw_comma matched_kw_base
  parens_call dot_op dot_identifier dot_do_identifier dot_ref
  dot_paren_identifier dot_punctuated_identifier dot_bracket_identifier
  var list bracket_access bit_string tuple
  fn_block do_block do_eol end_eol block_eol block_item block_list
  .

Terminals
  identifier kw_identifier punctuated_identifier
  bracket_identifier paren_identifier do_identifier block_identifier
  fn fn_paren 'end' '__ref__'
  number signed_number atom bin_string list_string sigil
  dot_call_op special_op comp_op
  'not' 'and' 'or' 'xor' 'when' 'in' 'do'
  'true' 'false' 'nil'
  '=' '+' '-' '*' '/' '++' '--' '**' '//'
  '(' ')' '[' ']' '{' '}' '<<' '>>'
  eol ','  '&' '|'  '.' '^' '@' '<-' '<>' '->'
  '&&' '||' '!'
  .

Rootsymbol grammar.

Left       5 do.
Right     10 '->'.
Left      20 ','.  % Solve nested call_args conflicts
Right     30 default_op.
Right     40 when_op.
Left      50 pipe_op.
Right     80 match_op.
Right     90 arrow_op.
Left     100 oror_op.
Left     110 andand_op.
Left     140 or_op.
Left     150 and_op.
Left     160 comp_expr_op.
Left     170 add_op.
Left     180 mult_op.
Right    190 bin_concat_op.
Right    200 addadd_op.
Right    210 multmult_op.
Nonassoc 280 unary_op.
Nonassoc 290 special_op.
Left     300 in_op.
Left     310 dot_call_op.
Left     310 dot_op.
Nonassoc 320 var.

%%% MAIN FLOW OF EXPRESSIONS

grammar -> eol : [nil].
grammar -> expr_list : lists:reverse('$1').
grammar -> eol expr_list : lists:reverse('$2').
grammar -> expr_list eol : lists:reverse('$1').
grammar -> eol expr_list eol : lists:reverse('$2').
grammar -> '$empty' : [nil].

% Note expressions are on reverse order
expr_list -> expr : ['$1'].
expr_list -> expr_list eol expr : ['$3'|'$1'].

expr -> matched_expr : '$1'.
expr -> unmatched_expr : '$1'.

matched_expr -> matched_expr matched_op_expr : build_op(element(1, '$2'), '$1', element(2, '$2')).
matched_expr -> unary_op matched_expr : build_unary_op('$1', '$2').
matched_expr -> special_op matched_expr : build_special_op('$1', '$2').
matched_expr -> fn_expr : '$1'.

unmatched_expr -> matched_expr op_expr : build_op(element(1, '$2'), '$1', element(2, '$2')).
unmatched_expr -> unmatched_expr op_expr : build_op(element(1, '$2'), '$1', element(2, '$2')).
unmatched_expr -> unary_op expr : build_unary_op('$1', '$2').
unmatched_expr -> special_op expr : build_special_op('$1', '$2').
unmatched_expr -> block_expr : '$1'.

op_expr -> match_op expr : { '$1', '$2' }.
op_expr -> add_op expr : { '$1', '$2' }.
op_expr -> mult_op expr : { '$1', '$2' }.
op_expr -> addadd_op expr : { '$1', '$2' }.
op_expr -> multmult_op expr : { '$1', '$2' }.
op_expr -> andand_op expr : { '$1', '$2' }.
op_expr -> oror_op expr : { '$1', '$2' }.
op_expr -> and_op expr : { '$1', '$2' }.
op_expr -> or_op expr : { '$1', '$2' }.
op_expr -> pipe_op expr : { '$1', '$2' }.
op_expr -> bin_concat_op expr : { '$1', '$2' }.
op_expr -> in_op expr : { '$1', '$2' }.
op_expr -> when_op expr : { '$1', '$2' }.
op_expr -> arrow_op expr : { '$1', '$2' }.
op_expr -> default_op expr : { '$1', '$2' }.
op_expr -> comp_expr_op expr : { '$1', '$2' }.

matched_op_expr -> match_op matched_expr : { '$1', '$2' }.
matched_op_expr -> add_op matched_expr : { '$1', '$2' }.
matched_op_expr -> mult_op matched_expr : { '$1', '$2' }.
matched_op_expr -> addadd_op matched_expr : { '$1', '$2' }.
matched_op_expr -> multmult_op matched_expr : { '$1', '$2' }.
matched_op_expr -> andand_op matched_expr : { '$1', '$2' }.
matched_op_expr -> oror_op matched_expr : { '$1', '$2' }.
matched_op_expr -> and_op matched_expr : { '$1', '$2' }.
matched_op_expr -> or_op matched_expr : { '$1', '$2' }.
matched_op_expr -> pipe_op matched_expr : { '$1', '$2' }.
matched_op_expr -> bin_concat_op matched_expr : { '$1', '$2' }.
matched_op_expr -> in_op matched_expr : { '$1', '$2' }.
matched_op_expr -> when_op matched_expr : { '$1', '$2' }.
matched_op_expr -> arrow_op matched_expr : { '$1', '$2' }.
matched_op_expr -> default_op matched_expr : { '$1', '$2' }.
matched_op_expr -> comp_expr_op matched_expr : { '$1', '$2' }.

block_expr -> parens_call call_args_parens do_block : build_identifier('$1', '$2' ++ '$3').
block_expr -> dot_punctuated_identifier call_args_no_parens do_block : build_identifier('$1', '$2' ++ '$3').
block_expr -> dot_do_identifier do_block : build_identifier('$1', '$2').
block_expr -> dot_identifier call_args_no_parens do_block : build_identifier('$1', '$2' ++ '$3').

fn_expr -> fn_paren call_args_parens fn_block : build_identifier('$1', '$2' ++ '$3').
fn_expr -> fn call_args_no_parens fn_block : build_identifier('$1', '$2' ++ '$3').
fn_expr -> fn fn_block : build_identifier('$1', '$2').
fn_expr -> fn_paren call_args_parens : build_identifier('$1', '$2').
fn_expr -> fn call_args_no_parens : build_identifier('$1', '$2').
fn_expr -> fn : build_identifier('$1', nil).
fn_expr -> call_expr : '$1'.

call_expr -> dot_punctuated_identifier call_args_no_parens : build_identifier('$1', '$2').
call_expr -> dot_identifier call_args_no_parens : build_identifier('$1', '$2').
call_expr -> dot_punctuated_identifier : build_identifier('$1', []).
call_expr -> dot_do_identifier : build_identifier('$1', nil).
call_expr -> var : build_identifier('$1', nil).
call_expr -> bracket_expr : '$1'.

bracket_expr -> dot_bracket_identifier bracket_access : build_access(build_identifier('$1', nil), '$2').
bracket_expr -> max_expr bracket_access : build_access('$1', '$2').
bracket_expr -> max_expr : '$1'.

max_expr -> parens_call call_args_parens : build_identifier('$1', '$2').
max_expr -> dot_ref : build_identifier('$1', nil).
max_expr -> base_expr : '$1'.
max_expr -> open_paren ')' : build_block([]).
max_expr -> open_paren expr_list close_paren : build_block('$2').

base_expr -> number : ?exprs('$1').
base_expr -> signed_number : { element(4, '$1'), ?line('$1'), ?exprs('$1') }.
base_expr -> atom : build_atom('$1').
base_expr -> list : '$1'.
base_expr -> tuple : '$1'.
base_expr -> '__ref__' : '$1'.
base_expr -> 'true' : ?op('$1').
base_expr -> 'false' : ?op('$1').
base_expr -> 'nil' : ?op('$1').
base_expr -> bin_string  : build_bin_string('$1').
base_expr -> list_string : build_list_string('$1').
base_expr -> bit_string : '$1'.
base_expr -> '&' : '$1'.
base_expr -> sigil : build_sigil('$1').

%% Blocks

fn_block -> '->' grammar 'end' : [[{do,build_block('$2', false)}]].

do_block -> do_eol 'end' : [[{do,nil}]].
do_block -> do_eol stab_expr_list end_eol : [[{ do, build_stab(lists:reverse('$2')) }]].
do_block -> do_eol block_list 'end' : [sort_kw([{ do, nil }|'$2'])].
do_block -> do_eol stab_expr_list eol block_list 'end' : [sort_kw([{ do, build_stab(lists:reverse('$2')) }|'$4'])].

do_eol -> 'do' : '$1'.
do_eol -> 'do' eol : '$1'.

end_eol -> 'end' : '$1'.
end_eol -> eol 'end' : '$2'.

block_eol -> block_identifier : '$1'.
block_eol -> block_identifier eol : '$1'.

stab_expr_list -> stab_expr : ['$1'].
stab_expr_list -> stab_expr_list eol stab_expr : ['$3'|'$1'].

stab_expr -> expr : '$1'.
stab_expr -> comma_expr stab_op expr : build_op('$2', lists:reverse('$1'), '$3').

block_item -> block_eol stab_expr_list eol : { ?exprs('$1'), build_stab(lists:reverse('$2')) }.
block_item -> block_eol : { ?exprs('$1'), nil }.

block_list -> block_item : ['$1'].
block_list -> block_item block_list : ['$1'|'$2'].

%% Helpers

var -> dot_identifier : '$1'.

comma_separator -> ','     : '$1'.
comma_separator -> ',' eol : '$1'.

open_paren -> '('      : '$1'.
open_paren -> '(' eol  : '$1'.
close_paren -> ')'     : '$1'.
close_paren -> eol ')' : '$2'.

open_bracket  -> '['     : '$1'.
open_bracket  -> '[' eol : '$1'.
close_bracket -> ']'     : '$1'.
close_bracket -> eol ']' : '$2'.

open_bit  -> '<<'     : '$1'.
open_bit  -> '<<' eol : '$1'.
close_bit -> '>>'     : '$1'.
close_bit -> eol '>>' : '$2'.

open_curly  -> '{'     : '$1'.
open_curly  -> '{' eol : '$1'.
close_curly -> '}'     : '$1'.
close_curly -> eol '}' : '$2'.

% Operators

add_op -> '+' : '$1'.
add_op -> '-' : '$1'.
add_op -> '+' eol : '$1'.
add_op -> '-' eol : '$1'.

mult_op -> '*' : '$1'.
mult_op -> '/' : '$1'.
mult_op -> '*' eol : '$1'.
mult_op -> '/' eol : '$1'.

addadd_op -> '++' : '$1'.
addadd_op -> '--' : '$1'.
addadd_op -> '++' eol : '$1'.
addadd_op -> '--' eol : '$1'.

multmult_op -> '**' : '$1'.
multmult_op -> '**' eol : '$1'.

default_op -> '//' : '$1'.
default_op -> '//' eol : '$1'.

unary_op -> '+' : '$1'.
unary_op -> '+' eol : '$1'.
unary_op -> '-' : '$1'.
unary_op -> '-' eol : '$1'.
unary_op -> '!' : '$1'.
unary_op -> '!' eol : '$1'.
unary_op -> '^' : '$1'.
unary_op -> '^' eol : '$1'.
unary_op -> 'not' : '$1'.
unary_op -> 'not' eol : '$1'.
unary_op -> '@' : '$1'.
unary_op -> '@' eol : '$1'.

match_op -> '=' : '$1'.
match_op -> '=' eol : '$1'.

andand_op -> '&&' : '$1'.
andand_op -> '&&' eol : '$1'.

oror_op -> '||' : '$1'.
oror_op -> '||' eol : '$1'.

and_op -> 'and' : '$1'.
and_op -> 'and' eol : '$1'.

or_op -> 'or' : '$1'.
or_op -> 'or' eol : '$1'.
or_op -> 'xor' : '$1'.
or_op -> 'xor' eol : '$1'.

pipe_op -> '|' : '$1'.
pipe_op -> '|' eol : '$1'.

bin_concat_op -> '<>' : '$1'.
bin_concat_op -> '<>' eol : '$1'.

in_op -> 'in' : '$1'.
in_op -> 'in' eol : '$1'.

when_op -> 'when' : '$1'.
when_op -> 'when' eol : '$1'.

stab_op -> '->' : '$1'.
stab_op -> '->' eol : '$1'.

arrow_op -> '<-' : '$1'.
arrow_op -> '<-' eol : '$1'.

comp_expr_op -> comp_op : '$1'.
comp_expr_op -> comp_op eol : '$1'.

% Dot operator

dot_op -> '.' : '$1'.
dot_op -> '.' eol : '$1'.

dot_identifier -> identifier : '$1'.
dot_identifier -> matched_expr dot_op identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_ref -> matched_expr dot_op '__ref__' : { '.', ?line('$2'), ['$1', '$3'] }.

dot_do_identifier -> do_identifier : '$1'.
dot_do_identifier -> matched_expr dot_op do_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_bracket_identifier -> bracket_identifier : '$1'.
dot_bracket_identifier -> matched_expr dot_op bracket_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_paren_identifier -> paren_identifier : '$1'.
dot_paren_identifier -> matched_expr dot_op paren_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_punctuated_identifier -> punctuated_identifier : '$1'.
dot_punctuated_identifier -> matched_expr dot_op punctuated_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

parens_call -> dot_paren_identifier : '$1'.
parens_call -> matched_expr dot_call_op : { '.', ?line('$2'), ['$1'] }. % Fun/local calls

% Function calls

matched_comma_expr -> matched_expr : ['$1'].
matched_comma_expr -> matched_comma_expr comma_separator matched_expr : ['$3'|'$1'].

call_args_no_parens -> matched_comma_expr : lists:reverse('$1').
call_args_no_parens -> matched_kw_base : ['$1'].
call_args_no_parens -> matched_comma_expr comma_separator matched_kw_base : lists:reverse(['$3'|'$1']).

comma_expr -> expr : ['$1'].
comma_expr -> comma_expr comma_separator expr : ['$3'|'$1'].

call_args_comma_expr -> comma_expr : lists:reverse('$1').
call_args_comma_expr -> kw_base : ['$1'].
call_args_comma_expr -> comma_expr comma_separator kw_base : lists:reverse(['$3'|'$1']).

call_args_parens -> open_paren ')' : [].
call_args_parens -> open_paren call_args_comma_expr close_paren : '$2'.

call_args -> call_args_comma_expr : '$1'.

% KV

kw_eol -> kw_identifier : '$1'.
kw_eol -> kw_identifier eol : '$1'.

kw_expr  -> kw_eol expr : {?exprs('$1'),'$2'}.
kw_comma -> kw_expr : ['$1'].
kw_comma -> kw_expr comma_separator kw_comma : ['$1'|'$3'].
kw_base  -> kw_comma : sort_kw('$1').

matched_kw_expr  -> kw_eol matched_expr : {?exprs('$1'),'$2'}.
matched_kw_comma -> matched_kw_expr : ['$1'].
matched_kw_comma -> matched_kw_expr comma_separator matched_kw_comma : ['$1'|'$3'].
matched_kw_base  -> matched_kw_comma : sort_kw('$1').

% Lists

bracket_access -> open_bracket ']' : { [], ?line('$1') }.
bracket_access -> open_bracket expr close_bracket : { '$2', ?line('$1') }.
bracket_access -> open_bracket kw_base close_bracket : { '$2', ?line('$1') }.

list -> open_bracket ']' : [].
list -> open_bracket kw_base close_bracket : '$2'.
list -> open_bracket expr close_bracket : ['$2'].
list -> open_bracket expr comma_separator call_args close_bracket : ['$2'|'$4'].

% Tuple

tuple -> open_curly '}' : build_tuple('$1', []).
tuple -> open_curly call_args close_curly :  build_tuple('$1', '$2').

% Bitstrings

bit_string -> open_bit '>>' : { '<<>>', ?line('$1'), [] }.
bit_string -> open_bit call_args close_bit : { '<<>>', ?line('$1'), '$2' }.

Erlang code.

-define(op(Node), element(1, Node)).
-define(line(Node), element(2, Node)).
-define(exprs(Node), element(3, Node)).

% The following directive is needed for (significantly) faster compilation
% of the generated .erl file by the HiPE compiler. Please do not remove.
-compile([{hipe,[{regalloc,linear_scan}]}]).

%% Operators

build_op(Op, Left, Right) when tuple_size(Op) == 3 ->
  { ?exprs(Op), ?line(Op), [Left, Right] };

build_op(Op, Left, Right) ->
  { ?op(Op), ?line(Op), [Left, Right] }.

build_unary_op(Op, Expr) ->
  { ?op(Op), ?line(Op), [Expr] }.

build_special_op(Op, Expr) ->
  { ?exprs(Op), ?line(Op), [Expr] }.

build_tuple(_Marker, [Left, Right]) ->
  { Left, Right };

build_tuple(Marker, Args) ->
  { '{}', ?line(Marker), Args }.

%% Blocks

build_block(Exprs) -> build_block(Exprs, true).

build_block([], _)                            -> nil;
build_block([nil], _)                         -> { '__block__', 0, [nil] };
build_block([Expr], _) when not is_list(Expr) -> Expr;
build_block(Exprs, true)                      -> { '__block__', 0, lists:reverse(Exprs) };
build_block(Exprs, false)                     -> { '__block__', 0, Exprs }.

%% Identifiers

build_identifier({ '.', DotLine, [Expr, { Kind, _, Identifier }] }, Args) when
  Kind == identifier; Kind == punctuated_identifier; Kind == bracket_identifier;
  Kind == paren_identifier; Kind == do_identifier ->
  build_identifier({ '.', DotLine, [Expr, Identifier] }, Args);

build_identifier({ '.', Line, _ } = Dot, Args) ->
  FArgs = case Args of
    nil -> [];
    _ -> Args
  end,
  { Dot, Line, FArgs };

build_identifier({ Keyword, Line }, Args) when Keyword == fn; Keyword == fn_paren ->
  { fn, Line, Args };

build_identifier({ _, Line, Identifier }, Args) ->
  { Identifier, Line, Args }.

%% Access

build_access(Expr, Access) ->
  { access, ?line(Access), [ Expr, ?op(Access) ] }.

%% Interpolation aware

build_sigil({ sigil, Line, Sigil, Parts, Modifiers }) ->
  { list_to_atom([$_,$_,Sigil,$_,$_]), Line, [ { '<<>>', Line, Parts }, Modifiers ] }.

build_bin_string({ bin_string, _Line, [H] }) when is_binary(H) -> H;
build_bin_string({ bin_string, Line, Args }) -> { '<<>>', Line, Args }.

build_list_string({ list_string, _Line, [H] }) when is_binary(H) -> binary_to_list(H);
build_list_string({ list_string, Line, Args }) -> { binary_to_list, Line, [{ '<<>>', Line, Args}] }.

build_atom({ atom, _Line, [H] }) when is_atom(H) -> H;
build_atom({ atom, _Line, [H] }) when is_binary(H) -> binary_to_atom(H, utf8);
build_atom({ atom, Line, Args }) -> { binary_to_atom, Line, [{ '<<>>', Line, Args}, utf8] }.

%% Keywords

build_stab([{ '->', Line, [Left, Right] }|T]) ->
  { '->', Line, build_stab(T, Left, [Right], []) };

build_stab(Else) ->
  build_block(Else, false).

build_stab([{ '->', _, [Left, Right] }|T], Marker, Temp, Acc) ->
  H = { Marker, build_block(Temp) },
  build_stab(T, Left, [Right], [H|Acc]);

build_stab([H|T], Marker, Temp, Acc) ->
  build_stab(T, Marker, [H|Temp], Acc);

build_stab([], Marker, Temp, Acc) ->
  H = { Marker, build_block(Temp) },
  lists:reverse([H|Acc]).

sort_kw(List) -> lists:sort(fun sort_kw/2, List).
sort_kw({ A, _ }, { B, _ }) -> A =< B.