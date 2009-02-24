From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Tue, 24 Feb 2009 14:44:23 +0800
Message-ID: <20090224064423.GA20706@gondor.apana.org.au>
References: <Pine.LNX.4.64.0902091513190.31742@wrl-59.cs.helsinki.fi> <20090221132424.GA28861@gondor.apana.org.au> <Pine.LNX.4.64.0902212042420.20526@wrl-59.cs.helsinki.fi> <20090221.235308.172360407.davem@davemloft.net> <b6a2187b0902232240m6f2347efs84639bb59a19269e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Chua <jeff.chua.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34263 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751476AbZBXGot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 01:44:49 -0500
Content-Disposition: inline
In-Reply-To: <b6a2187b0902232240m6f2347efs84639bb59a19269e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 02:40:30PM +0800, Jeff Chua wrote:
> On Sun, Feb 22, 2009 at 3:53 PM, David Miller <davem@davemloft.net> wrote:
> 
> > Sure, but I'll give Herbert one more chance :-)
> >
> > Applied to net-next-2.6
> 
> I see that this is already in linux-2.6.29-rc6. Tested and working fine.

Are you sure? It's not in my copy of rc6 :)

net-next-2.6 is for the release after the current one so the
earliest you're going to see this is in 2.6.30.

For now you'll either need to pull net-next-2.6 directly, use
linux-next, or apply the patch by hand.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
