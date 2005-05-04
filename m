From: folkert@vanheusden.com
Subject: Re: [PATCH] optimize check in port-allocation code
Date: Wed, 4 May 2005 09:15:20 +0200
Message-ID: <20050504071516.GA1008@vanheusden.com>
References: <20050420184419.GM20290@vanheusden.com>
	<20050424190427.11b4863e.davem@davemloft.net>
	<20050425061210.GB15167@vanheusden.com>
	<20050428120824.6cc9b345.davem@davemloft.net>
	<20050428212449.GC8774@vanheusden.com>
	<20050503143620.43cac50f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050503143620.43cac50f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > > I'll resend it as an attachment (see attachment).
> > > It still has spaces where there should be tabs, even though
> > > you compressed the patch and used attachment.
> > > The diff itself must already be corrupt before you attach
> > > it.
> > > Please double check that the patch you submit actually apply,
> > > this will save me a lot of wasted time.
> > Ok, I've redone them and tested if they patch cleanly, they now do.
> > See them attached.
> Both patches applied, thanks a lot.

What about moving that rover++ to the end of the loop? Was my
analysis correct?


Folkert van Heusden

-- 
Auto te koop, zie: http://www.vanheusden.com/daihatsu.php
Op zoek naar een IT of Finance baan? Mail me voor de mogelijkheden.
--------------------------------------------------------------------
 UNIX admin? Then give MultiTail (http://vanheusden.com/multitail/) 
 a try, it brings monitoring logfiles to a different level! See     
 http://vanheusden.com/multitail/features.html for a feature-list.  
--------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE
Get your PGP/GPG key signed at www.biglumber.com!
