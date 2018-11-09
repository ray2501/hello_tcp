%%%-------------------------------------------------------------------
%% @doc hello_tcp top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(hello_tcp_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_socket/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
-define(PORT, 9478).


%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).


%%====================================================================
%% Supervisor callbacks
%%====================================================================

init([]) ->
    {ok, ListenSocket} = gen_tcp:listen(?PORT, [{active,once}]),
    spawn_link(fun empty_listeners/0),
    {ok, 
       { 
         {simple_one_for_one, 60, 3600},
         [
             {hello_tcp_server, 
                 {hello_tcp_server, start_link, [ListenSocket]}, temporary, 1000, worker, [hello_tcp_server]
             }
         ]
       }
    }.


%%====================================================================
%% Internal functions
%%====================================================================

start_socket() ->
  supervisor:start_child(?MODULE, []).

empty_listeners() ->
  [start_socket() || _ <- lists:seq(1, 10)],
  ok.

