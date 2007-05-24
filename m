From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPv6] UDP Encapsulation of IPsec ESP Packets
Date: Thu, 24 May 2007 18:34:35 +1000
Message-ID: <E1Hr8mJ-00024X-00@gondolin.me.apana.org.au>
References: <1179744999.12746.88.camel@sebastian.intellilink.co.jp>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: fernando@oss.ntt.co.jp (Fernando Luis V??zquez Cao)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4405 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756095AbXEXIey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 04:34:54 -0400
In-Reply-To: <1179744999.12746.88.camel@sebastian.intellilink.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fernando Luis V??zquez Cao <fernando@oss.ntt.co.jp> wrote:
> I noticed that IPv4-over-IPv6 made into 2.6.21 (thank you!) and that
> prompted to check the progress with the implementation of rfc3948 (UDP
> Encapsulation of IPsec ESP Packets) in Linux. For IPv4 the code is
> already there, but that does not seem to be the case for IPv6. I have
> checked the usagi kernels and Dave S. Miller's net git tree and could
> not find anything.
> 
> Is anyone working on this? I would appreciate any information on the
> status of this work.

If we don't have NAT on IPv6 why would you need UDP encapsulation?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
