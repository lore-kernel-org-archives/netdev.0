From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Mon, 4 Nov 2013 15:03:36 +0800
Message-ID: <20131104070336.GA24148@gondor.apana.org.au>
References: <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104042913.GA23021@gondor.apana.org.au>
 <1383541254.4291.82.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104052321.GA23252@gondor.apana.org.au>
 <1383545155.4291.89.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104062202.GA23719@gondor.apana.org.au>
 <1383547581.4291.91.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:37472 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750829Ab3KDHDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 02:03:45 -0500
Content-Disposition: inline
In-Reply-To: <1383547581.4291.91.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 03, 2013 at 10:46:21PM -0800, Eric Dumazet wrote:
> On Mon, 2013-11-04 at 14:22 +0800, Herbert Xu wrote:
> 
> > So what NICs were you using that had this issue?
> 
> Its a generic issue, really.

I'd still like answer because we also tested large numbers of
flows and have not seen this.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
