-module(rahm_greeting_controller, [Req]).
-compile(export_all).

-include_lib("amqp_client/include/amqp_client.hrl").


pageview('GET', []) ->
	%% valid access
	Headers = [
  	{'Access-Control-Allow-Origin', "*"},
		{'Access-Control-Allow-Methods',  "GET, OPTIONS"},
    {'Content-Type',  "application/json"},
		{'Access-Control-Allow-Headers', "X-Requested-With"},
		{'Access-Control-Allow-Credentials', "true"},
		{'Access-Control-Max-Age', "180"}
	],

	%% url is page address
	Url = Req:query_param("url", ""),

	%% title is page content in tag:<title></title>
	Title = Req:query_param("title", ""),
 
	%% page_ts means timestamp when page load
	Page_ts = Req:query_param("page_ts", ""),

	%%browser means web browser name and version
	Browser = Req:query_param("browser", ""),

	%% width means web screen current width value
	Width = Req:query_param("width", ""),

	%% height means web screen current height value
	Height = Req:query_param("height", ""),

	%% uuid means normal access user(no-logined) or registed user(logined)
	Uuid = Req:query_param("uuid", ""),

  ClientIp = get_peer_id(),

  %% Database
  NewGreeting = pageview:new(id, Url, Title, Page_ts, Browser, Width, Height, Uuid, ClientIp),

  %% return
  case NewGreeting:validate() of
		ok ->

	    %% json data
      MqData = [
	   		{action,	"pageview"},
				{url, 		Url},
        {title, 	Title},
	   		{page_ts, 	Page_ts},
	      {browser, 	Browser},
     		{width, 	Width},
				{height, 	Height},
				{uuid, 		Uuid},
	   		{ip, 		ClientIp}
	    ],
      MqJson = jsx:encode(MqData),

	    %% Send RabbitMQ
      {ok, Connection} =
	   		amqp_connection:start(#amqp_params_network{host = "localhost"}),
	    {ok, Channel} = amqp_connection:open_channel(Connection),

	    amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),
	    amqp_channel:cast(Channel,
          #'basic.publish'{
						exchange = <<"">>,
				    routing_key = <<"hello">>},
        		#amqp_msg{payload = MqJson}),

			ok = amqp_channel:close(Channel),
      ok = amqp_connection:close(Connection),
            
			%% on success
			{json, [{code, 1}], Headers};

	  {error, ErrorList} ->
      %% on error
		  {json, [{code, 0}], Headers}

	end.

 
hello('GET', []) ->
	{output, "<strong>Rahm says hello!</strong>"}.


%% Get ipv4 client address
get_peer_id() ->
	%%Ip = Req:header("x-forwarded-for").
  Ip = tuple_to_list(Req:peer_ip()),
  [A,B,C,D] = Ip,
  integer_to_list(A) ++ "." ++ integer_to_list(B) ++ "." ++ integer_to_list(C) ++ "." ++ integer_to_list(D).

