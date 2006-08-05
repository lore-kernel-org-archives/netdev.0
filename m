From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPV6 possible recursive locking
Date: Sat, 05 Aug 2006 11:12:42 +1000
Message-ID: <E1G9AiY-0004go-00@gondolin.me.apana.org.au>
References: <44D3ECBB.6060901@linux.intel.com>
Cc: herbert@gondor.apana.org.au, vandrove@vc.cvut.cz,
	netdev@vger.kernel.org, mingo@elte.hu, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44292 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422690AbWHEBMx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 21:12:53 -0400
To: arjan@linux.intel.com (Arjan van de Ven)
In-Reply-To: <44D3ECBB.6060901@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven <arjan@linux.intel.com> wrote:
> 
> Hmm I remember fixing sk_clone before.. or was that skb_clone, I'd have ot check.
> Anyway I'll check this out either later today or tomorrow in more detail
> and will send a patch.

I vaguely recall you fixing it too.  I just couldn't find anything in
the mail archives :)

Perhaps the fix is hiding in mm somewhere and simply needs to go upstream.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
