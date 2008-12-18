From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Fri, 19 Dec 2008 10:02:53 +1100
Message-ID: <20081218230253.GA1855@gondor.apana.org.au>
References: <1229638581.3726.546.camel@calx> <E1LDRbc-0000Ro-1j@gondolin.me.apana.org.au> <20081218224905.2bc81664@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54053 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754133AbYLRXDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 18:03:09 -0500
Content-Disposition: inline
In-Reply-To: <20081218224905.2bc81664@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 10:49:05PM +0000, Alan Cox wrote:
>
> It was changed. The printer on fire ? bit was adjusted to make it clear
> because the original message *did* confuse and worry a few people.

Well

$ grep fire drivers/char/lp.c
                        printk(KERN_INFO "lp%d on fire\n", minor);
$ 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
