From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV6]: Fix IPsec datagram fragmentation
Date: Fri, 15 Feb 2008 18:38:07 +0800
Message-ID: <20080215103807.GA12915@gondor.apana.org.au>
References: <20080215062215.GA10735@gondor.apana.org.au> <OF3737A582.CBFC60B5-ON882573F0.002BE602-882573F0.002C7307@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, kazunori@miyazawa.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51780 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758072AbYBOKiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 05:38:20 -0500
Content-Disposition: inline
In-Reply-To: <OF3737A582.CBFC60B5-ON882573F0.002BE602-882573F0.002C7307@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2008 at 12:05:32AM -0800, David Stevens wrote:
>
> For the future, maybe we should rename that, or reverse
> the sense of it (in v4 as well). :-)

Yeah it really should be called local_mayfrag.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
