From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Fri, 25 Jul 2008 22:18:45 +0800
Message-ID: <E1KMO85-00052z-00@gondolin.me.apana.org.au>
References: <BAY103-DAV74E605DFBE7CC22EEA732B2870@phx.gbl>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pupilla@hotmail.com (Marco Berizzi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35263 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751160AbYGYOSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 10:18:52 -0400
In-Reply-To: <BAY103-DAV74E605DFBE7CC22EEA732B2870@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi <pupilla@hotmail.com> wrote:
> 
> Thanks for the reply.
> I got a similar error today also with 2.6.25.10
> after 20 days uptime.
> This box is running 2.6.25 since april 22: I have
> never seen these errors.

Pick one of these:

1) You have less RAM;
2) Your memory fragmentation has deteriorated;
3) Most likely: you were just lucky :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
