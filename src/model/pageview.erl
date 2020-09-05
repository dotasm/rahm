-module(pageview, [Id, Url, Title, Page_ts, Browser, Width, Height, Uuid, ClientIp]).
-compile(export_all).

validation_tests() ->
	[{fun() -> length(Page_ts) > 0 end,
  	{output, "Pageview timestamp must be non-empty!"}},
    	{fun() -> length(Page_ts) =< 20 end,
      	{output, "Pageview timestamp must be limited"}},

        	{fun() -> length(Url) > 0 end,
          	{output, "Url address must be non-empty!"}},

            	{fun() -> length(Browser) > 0 end,
              	{output, "Browser info must be non-empty!"}}
  ].

