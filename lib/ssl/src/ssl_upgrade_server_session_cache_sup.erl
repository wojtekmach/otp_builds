%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2020-2020. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%

%%
%%----------------------------------------------------------------------
%% Purpose: Supervisor for a listen options tracker
%%----------------------------------------------------------------------
-module(ssl_upgrade_server_session_cache_sup).

-behaviour(supervisor).

-include("ssl_internal.hrl").

%% API
-export([start_link/0,
         start_link_dist/0]).
-export([start_child/1]).

%% Supervisor callback
-export([init/1]).

%%%=========================================================================
%%%  API
%%%=========================================================================
start_link() ->
    supervisor:start_link({local, sup_name(normal)}, ?MODULE, []).

start_link_dist() ->
    supervisor:start_link({local, sup_name(dist)}, ?MODULE, []).

start_child(Type) ->
    SupName = sup_name(Type),
    Children = supervisor:count_children(SupName),
    Workers = proplists:get_value(workers, Children),
     case Workers of
        0 ->
             supervisor:start_child(SupName, [ssl_unknown_listener | ssl_config:pre_1_3_session_opts()]);
        1 ->
            [{_,Child,_, _}] = supervisor:which_children(SupName),
             {ok, Child}
    end.

%%%=========================================================================
%%%  Supervisor callback
%%%=========================================================================
init(_O) ->
    RestartStrategy = simple_one_for_one,
    MaxR = 3,
    MaxT = 3600,

    Name = undefined, % As simple_one_for_one is used.
    StartFunc = {ssl_server_session_cache, start_link, []},
    Restart = transient, % Should be restarted only on abnormal termination
    Shutdown = 4000,
    Modules = [ssl_server_session_cache],
    Type = worker,

    ChildSpec = {Name, StartFunc, Restart, Shutdown, Type, Modules},
    {ok, {{RestartStrategy, MaxR, MaxT}, [ChildSpec]}}.

sup_name(normal) ->
    ?MODULE;
sup_name(dist) ->
    list_to_atom(atom_to_list(?MODULE) ++ "_dist").