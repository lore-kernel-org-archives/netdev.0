From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: problem with 'net: Partially allow skb destructors to be used
	on receive path'
Date: Mon, 22 Jun 2009 22:56:42 +0800
Message-ID: <20090622145642.GA31280@gondor.apana.org.au>
References: <4A3CE170.8030604@hartkopp.net> <20090622122525.GA24481@gondor.apana.org.au> <4A3F8AC6.2070803@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34221 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756832AbZFVO4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 10:56:45 -0400
Content-Disposition: inline
In-Reply-To: <4A3F8AC6.2070803@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 03:44:38PM +0200, Oliver Hartkopp wrote:
>
> I tried to apply the patch on 2.6.30 also and only got some offsets (as expected).

Thanks for testing!

> Do you think, it's a good idea to queue this up for 2.6.30-stable?

If it's OK with Dave then it's OK with me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
