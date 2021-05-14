%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2020 Marc Worrell
%% @doc Calculate the eblurhash for an image file

%% Copyright 2020 Marc Worrell
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

-module(eblurhash).
-author('Marc Worrell <marc@worrell.nl>').

-export([
    magick/1,
    hash/3
]).


-spec magick( file:filename_all() ) -> {ok, binary()} | {error, nofile | format | convert}.
magick(File0) ->
    case os:find_executable("convert") of
        false ->
            {error, convert};
        Convert ->
            % Resize the file to a small gif
            TmpFile = tempfile(".gif"),
            File = unicode:characters_to_list(File0),
            Cmd = lists:flatten([
                os_filename(Convert),
                " ",
                os_filename(File),
                " "
                "-quantize YUV +dither -colors 256 "
                "-thumbnail 20x20 ",
                os_filename(TmpFile)
            ]),
            try
                os:cmd(Cmd),
                case read_gif_info(TmpFile) of
                    {ok, {Width, Height}} ->
                        Max = erlang:max(Width, Height),
                        X = erlang:max(erlang:round(Width * 5 / Max), 1),
                        Y = erlang:max(erlang:round(Height * 5 / Max), 1),
                        hash(X, Y, TmpFile);
                    {error, _} ->
                        {error, format}
                end
            after
                file:delete(TmpFile)
            end
    end.


-spec hash( X::1..9, Y::1..9, file:filename_all() ) -> {ok, binary()} | {error, nofile | format}.
hash(X, Y, File0) ->
    File = unicode:characters_to_list(File0),
    case {filelib:is_regular(File), is_supported(filename:extension(File))} of
        {true, true} ->
            PrivDir = code:priv_dir(eblurhash),
            Cmd = lists:flatten([
                    filename:join(PrivDir, "blurhash"),
                    " ",
                    integer_to_list(X), " ", integer_to_list(Y),
                    " ",
                    os_filename(File)
                ]),
            {ok, iolist_to_binary(dropspaces(os:cmd(Cmd)))};
        {false, _} ->
            {error, nofile};
        {_, false} ->
            {error, format}
    end.

is_supported(".png") -> true;
is_supported(".gif") -> true;
is_supported(".jpg") -> true;
is_supported(".jpeg") -> true;
is_supported(".PNG") -> true;
is_supported(".GIF") -> true;
is_supported(".JPG") -> true;
is_supported(".JPEG") -> true;
is_supported(_) -> false.

dropspaces(L) ->
    [ C || C <- L, C >= 32 ].


%% @doc Simple escape function for filenames as commandline arguments.
%% foo/"bar.jpg -> "foo/\"bar.jpg"; on windows "foo\\\"bar.jpg" (both including quotes!)
os_filename(A) when is_binary(A) ->
    os_filename(unicode:characters_to_list(A, utf8));
os_filename(A) when is_list(A) ->
    os_filename(lists:flatten(A), []).

os_filename([], Acc) ->
    filename:nativename([$'] ++ lists:reverse(Acc) ++ [$']);
os_filename([$\\|Rest], Acc) ->
    os_filename_bs(Rest, Acc);
os_filename([$'|Rest], Acc) ->
    os_filename(Rest, [$', $\\ | Acc]);
os_filename([C|Rest], Acc) ->
    os_filename(Rest, [C|Acc]).

os_filename_bs([$\\|Rest], Acc) ->
    os_filename(Rest, [$\\,$\\|Acc]);
os_filename_bs([$'|Rest], Acc) ->
    os_filename(Rest, [$',$\\,$\\,$\\|Acc]);
os_filename_bs([C|Rest], Acc) ->
    os_filename(Rest, [C,$\\|Acc]).


% Read the width and height of a GIF file
read_gif_info(File) ->
    case file:read_file(File) of
        {ok, <<"GIF87a",
              Width:16/little-unsigned-integer,
              Height:16/little-unsigned-integer,
              _/binary>>} ->
            {ok, {Width, Height}};
        {ok, <<"GIF89a",
              Width:16/little-unsigned-integer,
              Height:16/little-unsigned-integer,
              _/binary>>} ->
            {ok, {Width, Height}};
        {ok, _} ->
            {error, bad_magic};
        Error ->
            Error
    end.

%% @doc return a unique temporary filename with a set extension.
-spec tempfile(string()) -> file:filename().
tempfile(Extension) ->
    A = rand:uniform(100000000),
    B = rand:uniform(100000000),
    Filename = filename:join(temppath(), lists:flatten(io_lib:format("ztmp-~s-~p.~p~s",[node(),A,B,Extension]))),
    case filelib:is_file(Filename) of
        true -> tempfile(Extension);
        false -> Filename
    end.

%% @doc Returns the path where to store temporary files.
-spec temppath() -> file:filename().
temppath() ->
    lists:foldl(fun(false, Fallback) -> Fallback;
                   (Good, _) -> Good end,
                "/tmp",
                [os:getenv("TMP"), os:getenv("TEMP")]).
