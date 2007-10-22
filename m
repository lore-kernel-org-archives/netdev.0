From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netdev: Reset ipv4 flags during bundle creation on interfamily ipsec
Date: Mon, 22 Oct 2007 16:51:37 +0800
Message-ID: <20071022085137.GB17865@gondor.apana.org.au>
References: <E1IisnN-0003rh-00@gondolin.me.apana.org.au> <200710220955.53895.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4145 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754070AbXJVIvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 04:51:46 -0400
Content-Disposition: inline
In-Reply-To: <200710220955.53895.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 09:55:53AM +0300, Joakim Koskela wrote:
>
> Hi, and thanks for the feedback. True, this one affects only one level of 
> inter-family, and supporting more would require a lot more changes in the 
> bundle creation (perhaps combining both versions and taking better into 
> account the outer family of the last transformation..). 

I think I should have this fixed with my current tree.  I'll
either post that tonight or tomorrow.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
