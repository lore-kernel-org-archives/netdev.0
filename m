From: jamal <hadi@cyberus.ca>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 09:05:46 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204110901280.651-100000@shell.cyberus.ca>
References: <Pine.LNX.4.44.0204111536470.2204-100000@l>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0204111536470.2204-100000@l>
List-Id: netdev.vger.kernel.org



On Thu, 11 Apr 2002, Julian Anastasov wrote:

>
> 	Hello,
>
> > If i am not mistaken zebra is now capable of using more tables as well.
>
> 	Last time I checked it 6 months ago and today I don't see
> much progress on the web site but you can be right :)
>

hrm. Maybe its in their commercial version ;-<
Note how slow they are in updating it these days. Someone approached
me a while back with suggestions to join in forking (and liberate) Zebra
from the current (lack of) activity. My answer at the time is to put more
effort in Bird probably.

> 	Yes, we can ping indirect nexthops, do layer 7 health checks,
> alter the nexthops' weights. Usually we don't demand such super
> job from a routing daemon, the things are mostly "do it yourself" :)
>

My sentiments exactly. Any such beast when written should be policy
driven. If i dont need layer 7 health checks as stimulus, then
dont use them. Other things would be remote SNMP queries etc.

cheers,
jamal
