From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: AIM9 regression
Date: Wed, 24 Sep 2008 13:12:37 +0800
Message-ID: <20080924051237.GA6173@gondor.apana.org.au>
References: <48D93203.2050204@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41349 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750991AbYIXFMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 01:12:43 -0400
Content-Disposition: inline
In-Reply-To: <48D93203.2050204@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 01:14:27PM -0500, Christoph Lameter wrote:
> I just dont seem to be able to get 2.6.27 to behave in a speedy way network
> wise. Configured out various components (netfilter, etc etc) but I still keep
> getting these aim9 result against 2.6.22:

Could you please compare this against something less ancient,
like 2.6.26 perhaps?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
