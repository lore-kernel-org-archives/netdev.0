From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: XFRM does not rate limit messages from the kernel to userspace
Date: Tue, 23 Jan 2007 21:49:26 +1100
Message-ID: <E1H9JDS-0007aw-00@gondolin.me.apana.org.au>
References: <BAY103-DAV624D3E972A0B3ED4FE711B2AD0@phx.gbl>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3483 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932950AbXAWKt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 05:49:29 -0500
To: pupilla@hotmail.com (Marco Berizzi)
In-Reply-To: <BAY103-DAV624D3E972A0B3ED4FE711B2AD0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi <pupilla@hotmail.com> wrote:
> 
> AFAIK it was applied to osw 2.4.2
> Also changelog confirm this:
> 
> v2.4.2

Indeed.  Somehow I couldn't find the patch in the git tree that
I had here.  It wasn't the 2.4 branch though.

I presume you're using 2.4.x as well?

If so I'll neet to look at this again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
