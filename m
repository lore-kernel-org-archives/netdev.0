From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Tue, 23 Oct 2007 11:51:57 +0800
Message-ID: <E1IkAo9-0006xM-00@gondolin.me.apana.org.au>
References: <1193104400.5132.45.camel@localhost>
Cc: davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: joe@perches.com (Joe Perches)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3236 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751869AbXJWDwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 23:52:17 -0400
In-Reply-To: <1193104400.5132.45.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> wrote:
> On Mon, 2007-10-22 at 18:43 -0700, David Miller wrote:
>> Ok, but again did you test it?
> 
> Nope.  Stephen Hemminger did in 2003.

But your code differs significantly from Stephen's version.
However, if it is correct it does look like a good improvement.

So please write a simple test program.  It can't that bad since
there are only 65536 values to test :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
