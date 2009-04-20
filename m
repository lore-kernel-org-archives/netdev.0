From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] tun: Fix sk_sleep races when attaching/detaching
Date: Mon, 20 Apr 2009 17:35:49 +0800
Message-ID: <20090420093549.GA3356@gondor.apana.org.au>
References: <20090416110818.GA20950@gondor.apana.org.au> <20090416110952.GB20950@gondor.apana.org.au> <20090420083550.GA2582@gondor.apana.org.au> <20090420.022635.57839830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, kaber@trash.net, zabaljauregui@gmail.com,
	odie@cs.aau.dk, rusty@rustcorp.com.au, lguest@ozlabs.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	borntraeger@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52620 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753525AbZDTJg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:36:26 -0400
Content-Disposition: inline
In-Reply-To: <20090420.022635.57839830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 02:26:35AM -0700, David Miller wrote:
> 
> Do you think these two patches are ready to go into net-2.6
> now?

I think so.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
