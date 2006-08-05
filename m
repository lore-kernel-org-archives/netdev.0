From: David Miller <davem@davemloft.net>
Subject: Re: [3/7] [CRYPTO] api: Split out low-level API
Date: Sat, 05 Aug 2006 03:24:54 -0700 (PDT)
Message-ID: <20060805.032454.68062638.davem@davemloft.net>
References: <20060804133426.GB12832@gondor.apana.org.au>
	<20060805.014958.26300600.davem@davemloft.net>
	<20060805100652.GA20939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65442
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422805AbWHEKYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 06:24:45 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060805100652.GA20939@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 5 Aug 2006 20:06:52 +1000

> Sorry Dave, these patches weren't meant for the net-2.6.19 tree.
> They were supposed to enter -mm via the cryptodev tree.
> 
> I was just posting them for review.  I should've made that clearer
> at the start.

If I'm an explicit recipient and there's no "RFC" moniker in
the subject line I assume I should apply it :-)

The two patches I did apply were benign, so I'll leave them
in the net-2.6.19 tree
