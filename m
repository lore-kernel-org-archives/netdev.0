From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Wed, 2 Aug 2006 08:03:38 +1000
Message-ID: <20060801220338.GA11032@gondor.apana.org.au>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58893 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751179AbWHAWEZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 18:04:25 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44CE4DCA.8000609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 08:36:58PM +0200, Patrick McHardy wrote:
>
> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
> index 662a869..df1f4e5 100644
> --- a/net/netfilter/nf_queue.c
> +++ b/net/netfilter/nf_queue.c

I presume we need similar patches for the old ipv4/ipv6 versions as well?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
