From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: XFRM does not rate limit messages from the kernel to userspace
Date: Tue, 23 Jan 2007 20:30:02 +1100
Message-ID: <E1H9Hyc-0007MT-00@gondolin.me.apana.org.au>
References: <BAY103-DAV15A2D5D7F7F8DB53175163B2AD0@phx.gbl>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3053 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932911AbXAWJaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 04:30:06 -0500
To: pupilla@hotmail.com (Marco Berizzi)
In-Reply-To: <BAY103-DAV15A2D5D7F7F8DB53175163B2AD0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi <pupilla@hotmail.com> wrote:
> I'm experimenting the problem described in this
> bug report http://bugs.xelerance.com/view.php?id=726

It's actually a bug in openswan.  I even sent them a patch for
it back in June 2005:

http://bugs.xelerance.com/view.php?id=344

Unfortunately it probably doesn't apply anymore.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
