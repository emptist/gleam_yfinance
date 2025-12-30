-module(yfinance_http_native).
-export([http_get/6]).

%% HTTP GET request using Erlang's httpc with proxy support
%% Returns: {ok, {StatusCode, Body}} | {error, ErrorString}
http_get(Url, Timeout, ProxyHost, ProxyPort, ProxyUser, ProxyPass) ->
    try
        io:format("[DEBUG NATIVE] Function entered with params: ~p ~p ~p ~p ~p ~p~n", 
                 [Url, Timeout, ProxyHost, ProxyPort, ProxyUser, ProxyPass]),
        
        %% Ensure ssl is started first for HTTPS
        io:format("[DEBUG NATIVE] About to call ssl:start()~n"),
        case ssl:start() of
            ok -> ok;
            {error, {already_started, ssl}} -> ok;
            _Error -> ok
        end,
        
        %% Ensure inets is started
        case inets:start() of
            ok -> ok;
            {error, {already_started, inets}} -> ok;
            _Error2 -> ok
        end,
        
        %% Convert URL from binary (Gleam string) to char list if needed
        UrlStr = case is_binary(Url) of
            true -> binary_to_list(Url);
            false -> Url
        end,
        
        %% Set up headers to avoid 403 Forbidden
        Headers = [
            {"User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"},
            {"Accept", "application/json"},
            {"Accept-Language", "en-US,en;q=0.9"},
            {"Connection", "keep-alive"}
        ],
        
        io:format("[DEBUG NATIVE] Pattern matching on: ~p, ~p, ~p, ~p~n", [ProxyHost, ProxyPort, ProxyUser, ProxyPass]),
        
        FinalOptions = case {ProxyHost, ProxyPort, ProxyUser, ProxyPass} of
            {<<"no_proxy">>, _, _, _} ->
              io:format("[DEBUG NATIVE] No proxy configured (explicit no_proxy)~n"),
              %% Clear proxy environment variables
              os:putenv("http_proxy", ""),
              os:putenv("https_proxy", ""),
              os:putenv("HTTP_PROXY", ""),
              os:putenv("HTTPS_PROXY", ""),
              [{timeout, Timeout}];
            {Host, Port, User, Pass} when Host =/= <<>>, Host =/= "" ->
                io:format("[DEBUG NATIVE] Using proxy: ~p:~p~n", [Host, Port]),
                %% Convert host to char list for httpc
                ProxyHostStr = case is_binary(Host) of
                    true -> binary_to_list(Host);
                    false -> Host
                end,
                %% Convert credentials to char list
                ProxyUserStr = case is_binary(User) of
                    true -> binary_to_list(User);
                    false -> User
                end,
                ProxyPassStr = case is_binary(Pass) of
                    true -> binary_to_list(Pass);
                    false -> Pass
                end,
                
                %% Create proxy URL for environment variables
                ProxyAuth = case ProxyUserStr of
                  "" -> "";
                  _ -> ProxyUserStr ++ ":" ++ ProxyPassStr ++ "@"
                end,
                ProxyUrl = "http://" ++ ProxyAuth ++ ProxyHostStr ++ ":" ++ integer_to_list(Port),
                
                io:format("[DEBUG NATIVE] Setting proxy via environment: ~s~n", [ProxyUrl]),
                %% Set environment variables that httpc respects
                os:putenv("http_proxy", ProxyUrl),
                os:putenv("https_proxy", ProxyUrl),
                os:putenv("HTTP_PROXY", ProxyUrl),
                os:putenv("HTTPS_PROXY", ProxyUrl),
                
                %% Create proxy options for the request (not using set_options)
                [{timeout, Timeout}];
            {"no_proxy", _, _, _} ->
              io:format("[DEBUG NATIVE] No proxy configured (explicit no_proxy)~n"),
              %% Clear proxy environment variables
              os:putenv("http_proxy", ""),
              os:putenv("https_proxy", ""),
              os:putenv("HTTP_PROXY", ""),
              os:putenv("HTTPS_PROXY", ""),
              [{timeout, Timeout}];
            {"", _, _, _} ->
              io:format("[DEBUG NATIVE] No proxy configured (empty host)~n"),
              %% Clear proxy environment variables
              os:putenv("http_proxy", ""),
              os:putenv("https_proxy", ""),
              os:putenv("HTTP_PROXY", ""),
              os:putenv("HTTPS_PROXY", ""),
              [{timeout, Timeout}];
            _ ->
              io:format("[DEBUG NATIVE] No proxy configured (default case)~n"),
              %% Clear proxy environment variables
              os:putenv("http_proxy", ""),
              os:putenv("https_proxy", ""),
              os:putenv("HTTP_PROXY", ""),
              os:putenv("HTTPS_PROXY", ""),
              [{timeout, Timeout}]
        end,
        
        io:format("[DEBUG NATIVE] Making request to: ~s~n", [UrlStr]),
        
        case httpc:request(get, {UrlStr, Headers}, FinalOptions, []) of
            {ok, {{_, StatusCode, _}, _Headers, Body}} when is_list(Body) ->
                io:format("[DEBUG NATIVE] Success! Status: ~p, Body length: ~p~n", [StatusCode, length(Body)]),
                {ok, {StatusCode, Body}};
            {ok, {{_, StatusCode, _}, _Headers, Body}} when is_binary(Body) ->
                io:format("[DEBUG NATIVE] Success! Status: ~p, Body length: ~p~n", [StatusCode, byte_size(Body)]),
                {ok, {StatusCode, binary_to_list(Body)}};
            {error, Reason} ->
                io:format("[DEBUG NATIVE] Request failed: ~p~n", [Reason]),
                {error, lists:flatten(io_lib:format("~p", [Reason]))}
        end
    catch
        CatchError:CatchReason:Stacktrace ->
            io:format("[DEBUG NATIVE] Exception: ~p: ~p~nStack: ~p~n", [CatchError, CatchReason, Stacktrace]),
            {error, lists:flatten(io_lib:format("~p: ~p~n~p", [CatchError, CatchReason, Stacktrace]))}
    end.