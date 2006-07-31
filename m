From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: Fix protocol field value for outgoing IPv6 GSO packets
Date: Sun, 30 Jul 2006 21:08:19 -0700 (PDT)
Message-ID: <20060730.210819.01288662.davem@davemloft.net>
References: <44C56136.50600@trash.net>
	<20060725001326.GA18972@gondor.apana.org.au>
	<44CD81CD.3060503@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50089
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751436AbWGaEIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 00:08:52 -0400
To: kaber@trash.net
In-Reply-To: <44CD81CD.3060503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 31 Jul 2006 06:06:37 +0200

> Herbert Xu wrote:
> > On Tue, Jul 25, 2006 at 02:09:26AM +0200, Patrick McHardy wrote:
> > 
> >>[XFRM]: Fix protocol field value for outgoing IPv6 GSO packets
> >>
> >>Signed-off-by: Patrick McHardy <kaber@trash.net>
> > 
> > Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I believe you missed this one. Attached again for your convenience.

It's in my tree, but thanks for reminding me.
