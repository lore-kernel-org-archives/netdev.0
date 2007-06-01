From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] gso: Fix GSO feature mask in sk_setup_caps
Date: Fri, 1 Jun 2007 15:19:23 +1000
Message-ID: <20070601051923.GA13325@gondor.apana.org.au>
References: <20070601051349.GA13244@gondor.apana.org.au> <20070531.221622.62660702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3693 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753560AbXFAFT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 01:19:26 -0400
Content-Disposition: inline
In-Reply-To: <20070531.221622.62660702.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 31, 2007 at 10:16:22PM -0700, David Miller wrote:
> 
> I don't think it's worth bothering -stable with this one,
> agreed?

Not unless we're planning on making UFO use sk_setup_caps :)

Agreed!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
