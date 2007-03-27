From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Allow ip_summed to be forwarded as is
Date: Tue, 27 Mar 2007 15:26:40 +1000
Message-ID: <20070327052640.GA22937@gondor.apana.org.au>
References: <20070327052243.GA22442@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4023 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753152AbXC0F0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 01:26:41 -0400
Content-Disposition: inline
In-Reply-To: <20070327052243.GA22442@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 03:22:43PM +1000, Herbert Xu wrote:
> 
> [NET]: Allow ip_summed to be forwarded as is

Nevermind, that one is broken too.  I forgot to update the complete
checksums when forwarding.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
