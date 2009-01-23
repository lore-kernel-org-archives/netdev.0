From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: initialize xfrm encap_oa
Date: Sat, 24 Jan 2009 09:11:38 +1100
Message-ID: <20090123221137.GA806@gondor.apana.org.au>
References: <1232713828-6725-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52460 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756598AbZAWWLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 17:11:44 -0500
Content-Disposition: inline
In-Reply-To: <1232713828-6725-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2009 at 02:30:28PM +0200, Timo Teras wrote:
> Currently encap_oa is left uninitialized, so it contains garbage data which
> is visible to userland via Netlink. Initialize it by zeroing it out.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
