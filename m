From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pppoe: Add missing sock_put() in pppoe_rcv()
Date: Fri, 31 Oct 2008 12:26:46 +0800
Message-ID: <20081031042646.GA6056@gondor.apana.org.au>
References: <20081030085725.GA15289@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33028 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751151AbYJaE0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 00:26:55 -0400
Content-Disposition: inline
In-Reply-To: <20081030085725.GA15289@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2008 at 08:57:25AM +0000, Jarek Poplawski wrote:
> pppoe: Add missing sock_put() in pppoe_rcv()
> 
> Add missing sock_put() in pppoe_rcv() (introduced by
> commit 392fdb0e35055b96faa9c1cd6ab537805337cdce).
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Good cath!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
