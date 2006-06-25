From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 6/6] neighbour.c, pneigh_get_next() skips published entry
Date: Mon, 26 Jun 2006 00:47:58 +1000
Message-ID: <E1FuVu2-00053A-00@gondolin.me.apana.org.au>
References: <200606250847.k5P8lXH2020912@shell0.pdx.osdl.net>
Cc: davem@davemloft.net, netdev@vger.kernel.org, akpm@osdl.org,
	Jari.Takkala@q9.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4627 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932424AbWFYOst
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 10:48:49 -0400
To: akpm@osdl.org
In-Reply-To: <200606250847.k5P8lXH2020912@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> 
> [akpm: submitted before, discussion ended inconclusively, iirc]
> Signed-off-by: Andrew Morton <akpm@osdl.org>

I still need to try to reproduce this.  I might be able to allocate some
time on this soon.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
