From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] [IPV6] MIP6: Loadable module support for MIPv6.
Date: Thu, 24 May 2007 18:36:27 +1000
Message-ID: <20070524083627.GA8008@gondor.apana.org.au>
References: <11799066192758-git-send-email-nakam@linux-ipv6.org> <200705231154.33208.netdev@axxeo.de> <4654EEEB.1030603@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Oeser <netdev@axxeo.de>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4420 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756132AbXEXIgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 04:36:45 -0400
Content-Disposition: inline
In-Reply-To: <4654EEEB.1030603@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 24, 2007 at 10:48:27AM +0900, Masahide NAKAMURA wrote:
> 
> I prefer to use new macro like XFRM mode to unify XFRM
> protocols i.e. esp[46].c, ah[46].c, ipcomp[46].c, and mip6.c
> if we care about it. Can I add it as extensional patch
> if nobody has a plan to do this yet?

You're most welcome :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
