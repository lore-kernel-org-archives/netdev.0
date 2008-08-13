From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: csum offload and af_packet
Date: Wed, 13 Aug 2008 11:37:41 +1000
Message-ID: <20080813013741.GA30120@gondor.apana.org.au>
References: <20080813010935.GA29815@gondor.apana.org.au> <20080812.181731.249504809.davem@davemloft.net> <20080813012129.GA29996@gondor.apana.org.au> <20080812.182506.03341781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@axxeo.de, rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60965 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755126AbYHMBhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 21:37:54 -0400
Content-Disposition: inline
In-Reply-To: <20080812.182506.03341781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 06:25:06PM -0700, David Miller wrote:
> 
> Alexey was maintaining his own semi-fork of libpcap and tcpdump for
> years for the same reasons.

He had a whole suite of things, some of which are now finally
making it into the mainstream distros.

> Let's write a real packet capturing tool that will be fast and that we
> can add quick support for new kernel features to.
>
> I mean, what other alternative is there?  The pcap/tcpdump folks have
> had 10+ years to get their act in gear.

Maybe we could start from Alexey's code base.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
