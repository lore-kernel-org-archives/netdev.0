From: "Kyle C Quest" <kquest@unital.com>
Subject: Re: [PATCH] IPV6_V6ONLY Support, v2 (is Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port)
Date: Wed, 23 Oct 2002 12:09:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <01ed01c27aae$93693900$0506330a@leachlap5328>
References: <Pine.LNX.4.44.0210231905280.1533-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Pekka Savola" <pekkas@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > I'm just curious... what happened to the generic option, SO_ONEFAMILY,
that
> > would replace
> > the need for IPV6_V6ONLY?
>
> This kind of thing is only applicable to IPv4 and IPv6 (and badly even
> there), there is no use trying to generalize it -- the idea was discarded.
>

I see...
Thanks for the info
