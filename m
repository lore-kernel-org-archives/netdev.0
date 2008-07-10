From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] xfrm: Fix inter family IPsec tunnel handling again
Date: Thu, 10 Jul 2008 09:12:48 +0800
Message-ID: <20080710011248.GA20626@gondor.apana.org.au>
References: <20080705071950.GA26532@secunet.com> <20080705115654.GA18290@gondor.apana.org.au> <20080708095335.GP9549@secunet.com> <20080708104022.GA26280@gondor.apana.org.au> <20080709142418.GT9549@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35390 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753087AbYGJBNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 21:13:02 -0400
Content-Disposition: inline
In-Reply-To: <20080709142418.GT9549@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2008 at 04:24:18PM +0200, Steffen Klassert wrote:
>
> Just to get you right, do you mean something like the patch below?
> With this and a patched iproute2 I've got the inter family tunnels running.

Precisely.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
