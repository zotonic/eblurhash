-module(eblurhash_SUITE).

-compile([export_all, nowarn_export_all]).

-include_lib("common_test/include/ct.hrl").

%%--------------------------------------------------------------------
%% COMMON TEST CALLBACK FUNCTIONS
%%--------------------------------------------------------------------
init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_testcase(_TestCase, Config) ->
    Config.

end_per_testcase(_TestCase, _Config) ->
    ok.

all() ->
    [
        magick,
        hash
    ].

%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

magick(Config) ->
    File = filename:join(datadir(Config), "pic2.png"),
    {ok, Data} = eblurhash:magick(File),
    34 = size(Data),
    ok.

hash(Config) ->
    File = filename:join(datadir(Config), "pic2.png"),
    {ok,<<"MlMF%n00%#Mwo}S|WCWEM{a$R*bbWBbHfl">>} = eblurhash:hash(5, 3, File),
    ok.

datadir(Config) ->
    {data_dir, DataDir} = proplists:lookup(data_dir, Config),
    DataDir.
