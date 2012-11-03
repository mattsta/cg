-module(cg).

-export([start/0]).
-export([port/1, port/2]).
-export([host/1, host/2]).
-export([limit/1, limit/2]).

-import(proplists, [get_value/2]).

-define(SPACE(X), application:get_env(cg, X)).
%%%--------------------------------------------------------------------
%%% starting
%%%--------------------------------------------------------------------
start() ->
  application:start(cg).

%%%--------------------------------------------------------------------
%%% Get Local Config
%%%--------------------------------------------------------------------
% Config looks like:
% {cg, [
%  {beta, [
%   {riak_chatty, [
%    {host, "foo"},
%    {port, 3333},
%    {limit, 12}
%   ]}
%  ]},
%  {prod, [
%   {riak_chatty, [
%    {host, "boo"},
%    {port, 2221},
%    {limit, 3640}
%   ]}
%  ]}
% ]}

get_something(ServiceSpace, Service, What) ->
  Holder = ?SPACE(ServiceSpace),
  ServiceHolder = get_value(Service, Holder),
  % The holder can either be a proplist of detailed values
  % - OR -
  % it can just be one thing if e.g. we only ever care about
  % a port number.
  case ServiceHolder of
    S when is_list(S) -> get_value(What, ServiceHolder);
                    _ -> S
  end.

%%%--------------------------------------------------------------------
%%% Common Retrieval Types
%%%--------------------------------------------------------------------
port(Service) ->
  port(use_space(), Service).
port(Space, Service) ->
  get_something(Space, Service, port).

host(Service) ->
  host(use_space(), Service).
host(Space, Service) ->
  get_something(Space, Service, host).

limit(Service) ->
  limit(use_space(), Service).
limit(Space, Service) ->
  get_something(Space, Service, limit).

%%%--------------------------------------------------------------------
%%% Service Space Auto-Discovery
%%%--------------------------------------------------------------------
% If directory ends in -(SERVICESPACE), then return the space as an atom.
% common directory names could be foo-dev, foo-beta, foo-prod, etc.
use_space() ->
  LaunchDir = lists:last(string:tokens(filename:absname(""), "/")),
  case re:run(LaunchDir, "-(.*)$", [{capture, all_but_first, binary}]) of
    nomatch -> dev;
    {match, [BinSpace]} -> binary_to_atom(BinSpace, utf8)
  end.

%%%--------------------------------------------------------------------
%%% Provide Config over Network
%%%--------------------------------------------------------------------
% other apps should be able to connect to this app and merge config details.
