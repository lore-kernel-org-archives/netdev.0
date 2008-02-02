From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2.6 patch] xfrm4_beet_input(): fix an if()
Date: Sun, 3 Feb 2008 09:22:26 +1100
Message-ID: <20080202222226.GB31388@gondor.apana.org.au>
References: <20080202211635.GF9375@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47222 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762603AbYBBWWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 17:22:39 -0500
Content-Disposition: inline
In-Reply-To: <20080202211635.GF9375@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 02, 2008 at 11:16:35PM +0200, Adrian Bunk wrote:
> A bug every C programmer makes at some point in time...
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Good catch!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
