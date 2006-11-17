From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv4: ip_options_compile() how can we avoid blowing up on a NULL skb???
Date: Fri, 17 Nov 2006 16:28:12 +1100
Message-ID: <E1GkwGq-0004tw-00@gondolin.me.apana.org.au>
References: <200611162246.21018.dtor@insightbb.com>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	jesper.juhl@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48900 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1162231AbWKQF2b
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 00:28:31 -0500
To: dtor@insightbb.com (Dmitry Torokhov)
In-Reply-To: <200611162246.21018.dtor@insightbb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Torokhov <dtor@insightbb.com> wrote:
> 
> BUG()s there would be a mechanism to document invariants so next time
> someone is looking at the code there are no questions.

Well if someone is documenting this then wouldn't a comment (or even a
kerneldoc style block) be better?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
