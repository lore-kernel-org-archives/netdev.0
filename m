From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] [IPSEC]: Add ICMP host relookup support
Date: Wed, 12 Dec 2007 09:25:52 +0800
Message-ID: <20071212012552.GA20618@gondor.apana.org.au>
References: <20071211165317.GA16420@gondor.apana.org.au> <E1J28Nq-0004IU-00@gondolin.me.apana.org.au> <20071211.091056.161097349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4431 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751307AbXLLBZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 20:25:55 -0500
Content-Disposition: inline
In-Reply-To: <20071211.091056.161097349.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 09:10:56AM -0800, David Miller wrote:
> 
> This enumeration doesn't exist in my tree, what are you generating
> these patches against?

Sorry, I forgot to include the first patch because I made it
before the xfrm_lookup bug fix.

Here's the complete set against net-2.6.25.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
