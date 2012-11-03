-module(cg_tests).

-include_lib("eunit/include/eunit.hrl").

%%%----------------------------------------------------------------------
%%% Prelude
%%%----------------------------------------------------------------------
cg_test_() ->
  {setup,
    fun setup/0,
    fun teardown/1,
    [
     {"Test name",
       fun test_fun/0}
    ]
  }.

%%%----------------------------------------------------------------------
%%% Tests
%%%----------------------------------------------------------------------
test_fun() ->
  ?assertEqual(1, 1).

%%%----------------------------------------------------------------------
%%% Set it up, tear it down
%%%----------------------------------------------------------------------
setup() ->
  application:start(cg).

teardown(_) ->
  application:stop(cg).
