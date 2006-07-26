From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: Fix protocol field value for outgoing IPv6 GSO packets
Date: Wed, 26 Jul 2006 15:17:50 -0700 (PDT)
Message-ID: <20060726.151750.131945231.davem@davemloft.net>
References: <44C56136.50600@trash.net>
	<20060725001326.GA18972@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19589
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161015AbWGZWSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 18:18:00 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060725001326.GA18972@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 25 Jul 2006 10:13:26 +1000

> On Tue, Jul 25, 2006 at 02:09:26AM +0200, Patrick McHardy wrote:
> > This appears to be a mistake, but I didn't follow the GSO stuff
> > very closely, so there could be some non-obvious reason.
> 
> Yes it definitely was a mistake! Thanks for picking this up Patrick.
> 
> > [XFRM]: Fix protocol field value for outgoing IPv6 GSO packets
> > 
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks guys.
