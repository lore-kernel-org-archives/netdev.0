From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Network drivers that don't suspend on interface down
Date: Fri, 22 Dec 2006 12:03:04 +1100
Message-ID: <E1GxYoS-0003GL-00@gondolin.me.apana.org.au>
References: <20061220143134.GA25462@srcf.ucam.org>
Cc: arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4871 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1423175AbWLVBDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 20:03:54 -0500
To: mjg59@srcf.ucam.org (Matthew Garrett)
In-Reply-To: <20061220143134.GA25462@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Garrett <mjg59@srcf.ucam.org> wrote:
> 
> In terms of what I've seen on vaguely modern hardware, I'd guess at 
> e1000 and sky2 as the top ones. b44 is still common in cheaper hardware, 
> with via-rhine appearing at the very low end. I'll try to grep through 
> our hardware database results to get a stronger idea about percentages.

The Sony laptop that I bought a year ago still has an e100 chipset so
that's probably worth fixing too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
