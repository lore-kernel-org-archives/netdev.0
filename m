From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 21:26:09 +1000
Message-ID: <20080821112609.GA5052@gondor.apana.org.au>
References: <20080819091642.GI4376@ff.dom.local> <20080821100155.GA3621@ff.dom.local> <20080821.030523.205239441.davem@davemloft.net> <20080821101145.GA3963@ff.dom.local> <20080821101830.GB3963@ff.dom.local> <20080821102153.GB3789@gondor.apana.org.au> <20080821102338.GA3864@gondor.apana.org.au> <20080821103354.GA4079@ff.dom.local> <20080821105110.GA4088@gondor.apana.org.au> <20080821112055.GB4079@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44453 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756940AbYHUL0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 07:26:16 -0400
Content-Disposition: inline
In-Reply-To: <20080821112055.GB4079@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 11:20:56AM +0000, Jarek Poplawski wrote:
>
> I thought I described the problem quite clearly, except this error in
> the lock name. I certainly can miss much more things than you. And,
> after your answer I'm simply not sure if the question is still valid.

OK I've lost track of what you were trying to say.  Could you please
just restate the problem you saw?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
