From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/6] mv643xx_eth updates
Date: Fri, 20 Feb 2009 16:22:09 +0800
Message-ID: <20090220082209.GA18560@gondor.apana.org.au>
References: <20090219.235856.233995387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: buytenh@wantstofly.org, jeff@garzik.org, netdev@vger.kernel.org,
	nico@cam.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59787 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752388AbZBTIW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:22:26 -0500
Content-Disposition: inline
In-Reply-To: <20090219.235856.233995387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> I've already told you what I think.
> 
> Kill the kconfig option and try to help us make LRO have
> less of an impact in your tests.
> 
> You can throw a ton of numbers at me again, and I'll just
> say the same thing a third time.  And I'm OK with that :-)

Oh and if you're going to spend time optimising it please do so
with GRO instead of LRO which is going away.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
