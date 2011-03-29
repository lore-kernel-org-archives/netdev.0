From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] xfrm: Move the test on replay window size into the
	replay check functions
Date: Tue, 29 Mar 2011 14:20:06 +0800
Message-ID: <20110329062006.GA23079@gondor.apana.org.au>
References: <20110329054552.GI1290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54752 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733Ab1C2GUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 02:20:12 -0400
Content-Disposition: inline
In-Reply-To: <20110329054552.GI1290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2011 at 07:45:52AM +0200, Steffen Klassert wrote:
> As it is, the replay check is just performed if the replay window of the
> legacy implementation is nonzero. So we move the test on a nonzero replay
> window inside the replay check functions to be sure we are testing for the
> right implementation.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

for all 4 patches.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
