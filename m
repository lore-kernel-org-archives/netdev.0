From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH Round 3 0/2][RFC] Network Event Notifier Mechanism
Date: Wed, 28 Jun 2006 13:37:08 +1000
Message-ID: <20060628033708.GA4922@gondor.apana.org.au>
References: <20060627205050.30723.25753.stgit@stevo-desktop> <E1FvQBu-00018u-00@gondolin.me.apana.org.au> <20060628030400.GA4474@gondor.apana.org.au> <44A1F669.8070606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:27914 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750877AbWF1Dha
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 23:37:30 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <44A1F669.8070606@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 11:24:25PM -0400, Jeff Garzik wrote:
>
> I don't see how that position has changed?
> 
> http://linux-net.osdl.org/index.php/TOE

Well I must say that RDMA over TCP smells very much like TOE.  They've
got an ARP table, a routing table, and presumably a TCP stack.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
