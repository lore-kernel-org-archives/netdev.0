From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Sun, 12 Sep 2004 17:10:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912171045.2d54c11a.davem@davemloft.net>
References: <E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
	<20040908072408.GI27886@wotan.suse.de>
	<1094629677.1089.155.camel@jzny.localdomain>
	<20040908134713.1bcd46d3.davem@davemloft.net>
	<1094823215.1121.129.camel@jzny.localdomain>
	<20040911142116.GL4431@wotan.suse.de>
	<1094933731.2343.109.camel@jzny.localdomain>
	<20040911174535.2acbb957.davem@davemloft.net>
	<20040912100114.GB11484@havoc.gtf.org>
	<20040912102529.GA27096@wotan.suse.de>
	<20040912161604.GA23366@havoc.gtf.org>
	<1095010469.2344.215.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, ak@suse.de, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095010469.2344.215.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 12 Sep 2004 13:34:30 -0400
jamal <hadi@cyberus.ca> wrote:

> On Sun, 2004-09-12 at 12:16, Jeff Garzik wrote:
> 
> > 
> > Thanks, but still need a patch for return value constants, otherwise you
> > are compounding rather than addressing a current problem.
> 
> Something along the lines of attached patch?
> Francois needs to update the doc and you need someone to get the
> janitors enthusiastic (i just updated e1000)

Looks beautiful.  I added this patch and did the tg3 bits
in my local tree as well.

Thanks Jamal.
