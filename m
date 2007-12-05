From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Wed, 5 Dec 2007 20:57:58 +1100
Message-ID: <20071205095758.GA17471@gondor.apana.org.au>
References: <20071205071607.GA11852@gondor.apana.org.au> <20071204.233432.136250076.davem@davemloft.net> <20071205073927.GA12413@gondor.apana.org.au> <20071205.015558.224988608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon@fire.lp0.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1356 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751613AbXLEJ6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:58:05 -0500
Content-Disposition: inline
In-Reply-To: <20071205.015558.224988608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 01:55:58AM -0800, David Miller wrote:
>
> If it hits sysctl_tcp_syn_retries SYN attempts, the connect will hard
> fail.

Right.  Let's just forget about this until we have a queueing system :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
