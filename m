From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] generic network statistics (was Re: [6/6]: jenkins
 hash for neigh / Statistics)
Date: Tue, 28 Sep 2004 14:43:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928144356.371ef3d4.davem@davemloft.net>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	<E1CBu70-00010X-00@gondolin.me.apana.org.au>
	<20040927121403.767e2308.davem@davemloft.net>
	<20040927222613.GE3236@sunbeam.de.gnumonks.org>
	<20040927160636.7741d973.davem@davemloft.net>
	<1096327658.1729.19.camel@localhost.localdomain>
	<16729.9326.93269.422940@robur.slu.se>
	<20040928111906.GB29961@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, shemminger@osdl.org,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040928111906.GB29961@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 13:19:06 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> Please find the current kernel-part patch attached to this mail,
> it adds teplate-headerlines and moves all statistics files to
> /proc/net/stat.  It even cleans up the neigh_stat code a bit.
> Depends on my latest neighbour statistics patch that davem has already
> merged.

I like this patch a lot and have applied it.

Thanks Harald.

Harald, we've created a lot of churn over the past week or
two.  Can I expect a set of 2.4.x patches for all the neigh
stuff and this generic statistics thing sometime soon?
