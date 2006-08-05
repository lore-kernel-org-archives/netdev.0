From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [3/7] [CRYPTO] api: Split out low-level API
Date: Sat, 5 Aug 2006 20:36:23 +1000
Message-ID: <20060805103623.GA21257@gondor.apana.org.au>
References: <20060804133426.GB12832@gondor.apana.org.au> <20060805.014958.26300600.davem@davemloft.net> <20060805100652.GA20939@gondor.apana.org.au> <20060805.032454.68062638.davem@davemloft.net> <20060805103201.GA21184@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2573 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422811AbWHEKga
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 06:36:30 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060805103201.GA21184@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2006 at 08:32:01PM +1000, herbert wrote:
> 
> > The two patches I did apply were benign, so I'll leave them
> > in the net-2.6.19 tree
> 
> No problems.

Actually, I just tried to rebase my tree without those two patches
and it ended in disaster since they both touch areas patched later
on.

So in order to avoid us being crucified by Andrew :), it'd be
great if you could back out those two patches from net-2.6.19.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
