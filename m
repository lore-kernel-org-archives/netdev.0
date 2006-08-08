From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 8 Aug 2006 22:39:19 +1000
Message-ID: <20060808123919.GA15625@gondor.apana.org.au>
References: <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net> <1154797002.5081.21.camel@jzny2> <20060805230517.GA25468@gondor.apana.org.au> <1154819868.5517.34.camel@jzny2> <20060805231959.GA25768@gondor.apana.org.au> <1154821010.5517.48.camel@jzny2> <20060806025123.GA27051@gondor.apana.org.au> <1155039718.5138.58.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11525 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964868AbWHHMkS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 08:40:18 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155039718.5138.58.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 08:21:58AM -0400, jamal wrote:
> 
> Is the patch below making it in? As i pointed out in another email
> tests reveal it is good.

I'll write up a proper description and submit it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
