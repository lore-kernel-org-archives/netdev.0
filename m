From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPv4] UFO: prevent generation of chained skb
Date: Tue, 29 Apr 2008 22:37:47 -0700 (PDT)
Message-ID: <20080429.223747.211215854.davem@davemloft.net>
References: <BAY121-W44CAF03A4C79BFC4FEEEBDB6DE0@phx.gbl>
	<20080429.032714.263350536.davem@davemloft.net>
	<20080429120713.GA19937@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bkostya@hotmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751214AbYD3Fhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 01:37:48 -0400
In-Reply-To: <20080429120713.GA19937@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 29 Apr 2008 20:07:13 +0800

> On Tue, Apr 29, 2008 at 03:27:14AM -0700, David Miller wrote:
> >
> > Mostly this looks fine to me.
> > 
> > Herbert, can you take a quick look at this?
> 
> Yep looks good to me too.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.

K, I had to fix up your patch by hand because your email
client corrupted the patch, changing tabs into space
characters, and things of that nature.

Also, your patch description had many lines longer than
80 columns, which I had to fix up as well.

I'm happy to do this before you are aware of the problem,
like this time, but now that I've made you aware I will
push back future patches which have these errors.

Thank you.
