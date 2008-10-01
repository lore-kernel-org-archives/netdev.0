From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 1 Oct 2008 22:05:14 +0800
Message-ID: <20081001140514.GC13749@gondor.apana.org.au>
References: <20080925094905.GA19180@gondor.apana.org.au> <48DB801E.90500@iki.fi> <48DB85B4.10104@iki.fi> <20081001.030753.246288202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45080 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751341AbYJAOFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 10:05:22 -0400
Content-Disposition: inline
In-Reply-To: <20081001.030753.246288202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 01, 2008 at 03:07:53AM -0700, David Miller wrote:
>
> > The right place to do that would be pfkey_release, I assume?
> 
> I reread this thread, and the most recent patch seems good
> and even tested :-)  But it seems that you want to make some
> more tweaks, right?
> 
> Please post explicitly the patch you want me to apply to
> net-next-2.6 once you reach that point, thanks!

Yes I think Timo is still touching it up.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
