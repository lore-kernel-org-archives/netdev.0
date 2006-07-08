From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Sat, 08 Jul 2006 13:11:27 +1000
Message-ID: <E1Fz3E7-0000EU-00@gondolin.me.apana.org.au>
References: <20060707.165527.77037268.davem@davemloft.net>
Cc: shemminger@osdl.org, hch@lst.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33035 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932498AbWGHDLy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 23:11:54 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060707.165527.77037268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>> What is the point of dev_alloc_skb anyway? all it does is add header space.
> 
> In stone-age times it actually had specific semantics, but yes today
> it is just a synonym.

Does anyone still need those 16 bytes of header space?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
