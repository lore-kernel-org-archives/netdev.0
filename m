From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] generic network statistics (was Re: [6/6]: jenkins
	hash for neigh / Statistics)
Date: 28 Sep 2004 22:16:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096424171.1041.87.camel@jzny.localdomain>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	 <E1CBu70-00010X-00@gondolin.me.apana.org.au>
	 <20040927121403.767e2308.davem@davemloft.net>
	 <20040927222613.GE3236@sunbeam.de.gnumonks.org>
	 <20040927160636.7741d973.davem@davemloft.net>
	 <1096327658.1729.19.camel@localhost.localdomain>
	 <16729.9326.93269.422940@robur.slu.se>
	 <20040928111906.GB29961@sunbeam.de.gnumonks.org>
	 <1096375700.8659.235.camel@jzny.localdomain>
	 <16729.29634.992171.862677@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>,
        Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16729.29634.992171.862677@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 10:22, Robert Olsson wrote:
>  OK it's EWMA calc in kernel. 
[..]
> As usual most code is honestly stolen from Alexey. :-)

>From the maestro himself ;-> Why reinvent music my friend?
You are probably using the same code. I just ripped it from netsched
and made it available to the general masses.
BTW, if you see any missing tricks there let me know

cheers,
jamal
