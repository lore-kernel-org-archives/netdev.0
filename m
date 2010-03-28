From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Sun, 28 Mar 2010 16:22:50 +0800
Message-ID: <20100328082250.GA14053@gondor.apana.org.au>
References: <20100327.203120.98894145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:57007 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753789Ab0C1IWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 04:22:55 -0400
Content-Disposition: inline
In-Reply-To: <20100327.203120.98894145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 27, 2010 at 08:31:20PM -0700, David Miller wrote:
>
> Finally, we can really move the metrics array into the inetpeer
> entries.

My main question is how do we deal with source-address policy
routing in a host cache?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
