From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPv4] UFO: prevent generation of chained skb
Date: Tue, 29 Apr 2008 20:07:13 +0800
Message-ID: <20080429120713.GA19937@gondor.apana.org.au>
References: <BAY121-W44CAF03A4C79BFC4FEEEBDB6DE0@phx.gbl> <20080429.032714.263350536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bkostya@hotmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46916 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750981AbYD2MHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 08:07:17 -0400
Content-Disposition: inline
In-Reply-To: <20080429.032714.263350536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 03:27:14AM -0700, David Miller wrote:
>
> Mostly this looks fine to me.
> 
> Herbert, can you take a quick look at this?

Yep looks good to me too.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
