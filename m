From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Make UFO on master device independent of attached
	devices
Date: Thu, 8 Oct 2009 07:41:53 +0800
Message-ID: <20091007234152.GB21965@gondor.apana.org.au>
References: <1254954265.31575.191.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38607 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755692AbZJGXme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 19:42:34 -0400
Content-Disposition: inline
In-Reply-To: <1254954265.31575.191.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 07, 2009 at 03:24:25PM -0700, Sridhar Samudrala wrote:
> Now that software UFO is supported, UFO can be enabled on master
> devices like bridge, bond even though the attached device doesn't
> support this feature in hardware.
> 
> This allows UFO to be used between KVM host and guest even when a
> physical interface attached to the bridge doesn't support UFO.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
