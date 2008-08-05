From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge: Eliminate unnecessary forward delay
Date: Tue, 5 Aug 2008 16:55:17 +0800
Message-ID: <20080805085517.GA20881@gondor.apana.org.au>
References: <20080804170439.GA13546@gondor.apana.org.au> <20080804103534.6b7896d9@extreme> <20080805021240.GA18159@gondor.apana.org.au> <20080805.014006.00973775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39288 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758601AbYHEIzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 04:55:23 -0400
Content-Disposition: inline
In-Reply-To: <20080805.014006.00973775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 01:40:06AM -0700, David Miller wrote:
>
> So when p->state is not BR_STATE_BLOCKING, both before and after this
> patch, the function does nothing.

Thanks for pointing this out.

> Are your concerns still present?  I'd like to apply this, so let me know.

No it looks good to me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
