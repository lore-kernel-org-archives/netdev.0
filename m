From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/5] virtio net: Allow receiving SG packets
Date: Tue, 15 Jul 2008 16:52:41 +0800
Message-ID: <20080715085241.GB4285@gondor.apana.org.au>
References: <200807151341.39337.rusty@rustcorp.com.au> <20080715035209.GB2657@gondor.apana.org.au> <200807151825.04627.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37652 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755456AbYGOIw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 04:52:56 -0400
Content-Disposition: inline
In-Reply-To: <200807151825.04627.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2008 at 06:25:04PM +1000, Rusty Russell wrote:
>
> Oops.  I grepped for LRO when I did this and found nothing.
> 
> How's this one?

Looks good.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
