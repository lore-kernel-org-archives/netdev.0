From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/8] net: Generic Receive Offload
Date: Sat, 13 Dec 2008 12:34:20 +1100
Message-ID: <20081213013420.GA13549@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52022 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753282AbYLMBeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 20:34:24 -0500
Content-Disposition: inline
In-Reply-To: <20081212053116.GA2927@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 04:31:16PM +1100, Herbert Xu wrote:
> 
> This patch series introduces the Generic Receive Offload system.  Just
> as GSO generalised TSO, GRO does the same thing for LRO.  Most of the
> technical details are pulled straight out of LRO, although there is no
> code shared between them.

I've incorporated fixes to the bugs reported against this series and
here is an updated version.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
