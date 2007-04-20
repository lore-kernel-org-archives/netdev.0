From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Getting the new RxRPC patches upstream
Date: Fri, 20 Apr 2007 11:15:02 +1000
Message-ID: <E1HehiI-0003py-00@gondolin.me.apana.org.au>
References: <20070419.131448.71554303.davem@davemloft.net>
Cc: dhowells@redhat.com, ebiederm@xmission.com, akpm@osdl.org,
	containers@lists.osdl.org, oleg@tv-sign.ru, hch@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1821 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753366AbXDTBQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 21:16:05 -0400
In-Reply-To: <20070419.131448.71554303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> I applied already the patches I thought were appropriate,
> you had some crypto layer changes that you need to work
> out with Herbert Xu before the rest can be applied.

He has already fixed it by using the scatterlist interface for now.
So the last set of patches he posted is ready for merging into
net-2.6.22.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
