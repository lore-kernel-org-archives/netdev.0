From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL, resend] async_tx/dmaengine update for 2.6.29
Date: Mon, 12 Jan 2009 23:15:39 +1100
Message-ID: <20090112121539.GA6058@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, hskinnemoen@atmel.com,
	maciej.sosnowski@intel.com, g.liakhovetski@gmx.de,
	sfr@canb.auug.org.au, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, "David S. Miller" <davem@davemloft.net>
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54859 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751599AbZALMQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 07:16:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dan.j.williams@intel.com> wrote:
>
> net/core/dev.c                        |  149 +------
> net/ipv4/tcp.c                        |    5 +-
> net/ipv4/tcp_input.c                  |    2 +-
> net/ipv4/tcp_ipv4.c                   |    2 +-
> net/ipv6/tcp_ipv6.c                   |    2 +-

Wouldn't it be better for these changes to go through the net
tree?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
