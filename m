From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [LIB]: Introduce struct pcounter
Date: Wed, 21 Nov 2007 22:09:29 +0800
Message-ID: <20071121140929.GA31033@gondor.apana.org.au>
References: <20071107161615.GL27345@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, dada1@cosmosbay.com,
	netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3852 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753909AbXKUOJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 09:09:48 -0500
Content-Disposition: inline
In-Reply-To: <20071107161615.GL27345@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 04:16:15PM +0000, Arnaldo Carvalho de Melo wrote:
> This just generalises what was introduced by Eric Dumazet for the struct proto
> inuse field in 286ab3d46058840d68e5d7d52e316c1f7e98c59f:
> 
>     [NET]: Define infrastructure to keep 'inuse' changes in an efficent SMP/NUMA way.
> 
> Please look at the comment in there to see the rationale.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Both patches applied.  Thanks Arnaldo!

This patch had some trailing white spaces picked up by git which
I've fixed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
