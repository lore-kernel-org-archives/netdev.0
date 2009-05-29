From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Fri, 29 May 2009 12:23:13 -0400
Message-ID: <20090529162312.GA5191@neterion.com>
References: <20090527044539.GA32372@gondor.apana.org.au> <20090527175223.GB7804@neterion.com> <20090527230858.GA24278@gondor.apana.org.au> <20090528152143.GA4501@neterion.com> <20090529092821.GA11725@gondor.apana.org.au> <20090529092930.GA11785@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:43264 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483AbZE2QXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 12:23:24 -0400
Content-Disposition: inline
In-Reply-To: <20090529092930.GA11785@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 07:29:30PM +1000, Herbert Xu wrote:
> Oh and when you say GRO off, is that with it turned off using
> ethtool or with the GRO patch to your driver reverted?

It's just being turned off by setting a loadable module option.

		-ben
