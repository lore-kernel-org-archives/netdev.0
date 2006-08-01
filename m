From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 1 Aug 2006 17:04:28 +1000
Message-ID: <20060801070428.GA3802@gondor.apana.org.au>
References: <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <20060801.000059.57444384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:18957 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932517AbWHAHEm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 03:04:42 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060801.000059.57444384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 12:00:59AM -0700, David Miller wrote:
> 
> I'm going to kill the warning for 2.6.18, using the patch below.
> We can queue up Patrick's changes for 2.6.19, just give me the
> word and I'll apply it to net-2.6.19

Thanks Dave.  This should give us plenty of time to produce a
complete solution to the problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
