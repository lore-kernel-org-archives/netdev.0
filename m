From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 14 Mar 2005 21:51:22 -0800
Message-ID: <20050314215122.356ea961.davem@davemloft.net>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au>
	<422AF8D0.3010905@trash.net>
	<20050307012458.GA4335@gondor.apana.org.au>
	<422BB14A.5030302@trash.net>
	<20050307014337.GA4451@gondor.apana.org.au>
	<422BB477.3040607@trash.net>
	<20050307015943.GA4533@gondor.apana.org.au>
	<422BBCC2.4010706@trash.net>
	<20050307025723.GA4818@gondor.apana.org.au>
	<422BC655.5070907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <422BC655.5070907@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 07 Mar 2005 04:11:17 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Herbert Xu wrote:
> > The reason I'm asking is because the places where you're most likely
> > to use tos/fwmark is in IPsec gateways.  In other words, it isn't
> > very useful unless it works in tunnel mode.  This plus the fact
> > that the check for tunnel mode is a bit of a hack makes me think that
> > it's not worth it at the moment.
> 
> Ok, let's drop it for now.

Can someone send me an updated patch (with changelog msg please)?
Thanks.
