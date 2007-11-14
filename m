From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Wed, 14 Nov 2007 18:04:58 +0800
Message-ID: <20071114100458.GA13123@gondor.apana.org.au>
References: <20071114062834.GB11173@gondor.apana.org.au> <20071113.223356.216207937.davem@davemloft.net> <20071114063657.GA11293@gondor.apana.org.au> <20071114.015812.77787863.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1396 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750905AbXKNKPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 05:15:31 -0500
Content-Disposition: inline
In-Reply-To: <20071114.015812.77787863.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 01:58:12AM -0800, David Miller wrote:
>
> >From d15f51674f6e9985c84f221a7fd1026eafbe42c8 Mon Sep 17 00:00:00 2001
> From: David S. Miller <davem@sunset.davemloft.net>
> Date: Wed, 14 Nov 2007 01:57:47 -0800
> Subject: [PATCH] [IPSEC]: Kill afinfo->nf_post_routing
> 
> After changeset:
> 
> 	[NETFILTER]: Introduce NF_INET_ hook values
> 
> It always evaluates to NF_INET_POST_ROUTING.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Thank you!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
