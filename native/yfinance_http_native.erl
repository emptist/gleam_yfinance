-module(yfinance_http_native).
-export([http_get/3]).

%% HTTP GET request using Erlang's httpc with proxy support
%% Returns: {ok, {StatusCode, Body}} | {error, ErrorString}
http_get(Url, _Timeout, ProxyConfig) ->
    try
        %% Ensure ssl is started first for HTTPS
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
        
        %% Set up proxy via environment variables (more reliable than httpc options)
        {UseProxy, HTTPOptions} = case ProxyConfig of
            {ProxyHost, ProxyPort} when ProxyHost =/= <<"no_proxy">>, ProxyHost =/= <<"">> ->
                %% Convert binary host to char list for httpc
                ProxyHostStr = binary_to_list(ProxyHost),
                ProxyUrl = "http://" ++ ProxyHostStr ++ ":" ++ integer_to_list(ProxyPort),
                io:format("[DEBUG NATIVE] Setting proxy via environment: ~s~n", [ProxyUrl]),
                %% Set environment variables that httpc respects
                os:putenv("http_proxy", ProxyUrl),
                os:putenv("https_proxy", ProxyUrl),
                os:putenv("HTTP_PROXY", ProxyUrl),
                os:putenv("HTTPS_PROXY", ProxyUrl),
                %% Also try setting via httpc:set_options
                ProxyOption = {proxy, {{ProxyHostStr, ProxyPort}, []}},
                case httpc:set_options([ProxyOption]) of
                    ok ->
                        io:format("[DEBUG NATIVE] Proxy also accepted by httpc:set_options~n"),
                        ok;
                    {error, _Reason} ->
                        io:format("[DEBUG NATIVE] httpc:set_options failed (but env vars are set)~n"),
                        ok
                end,
                %% Return empty options since proxy is set via env vars
                {true, []};
            _ ->
                io:format("[DEBUG NATIVE] No proxy configured~n"),
                %% Clear proxy environment variables
                os:putenv("http_proxy", ""),
                os:putenv("https_proxy", ""),
                os:putenv("HTTP_PROXY", ""),
                os:putenv("HTTPS_PROXY", ""),
                {false, []}
        end,
        
        %% Make a simple HTTP request using the URL string directly
        %% Use timeout of 10 seconds (10000 ms) for all requests
        TimeoutOption = {timeout, 10000},
        RequestOptions = HTTPOptions ++ [TimeoutOption],
        
        %% Add SSL options for HTTPS URLs
        SSLOptions = case UseProxy of
            true -> [];
            false -> [{ssl, [{verify, verify_none}]}]
        end,
        FinalOptions = RequestOptions ++ SSLOptions,
        
        case httpc:request(get, {UrlStr, Headers}, FinalOptions, []) of
            {ok, {{_, StatusCode, _}, _Headers, Body}} when is_list(Body) ->
                {ok, {StatusCode, Body}};
            {ok, {{_, StatusCode, _}, _Headers, Body}} when is_binary(Body) ->
                {ok, {StatusCode, binary_to_list(Body)}};
            {error, Reason} ->
                {error, lists:flatten(io_lib:format("~p", [Reason]))}
        end
    catch
        CatchError:CatchReason:Stacktrace ->
            {error, lists:flatten(io_lib:format("~p: ~p~n~p", [CatchError, CatchReason, Stacktrace]))}
    end.