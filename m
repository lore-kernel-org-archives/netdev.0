From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: hard_start_xmit  conext
Date: Wed, 16 Aug 2006 20:22:28 +1000
Message-ID: <20060816102228.GA28398@gondor.apana.org.au>
References: <E1GDBlk-0006O1-00@gondolin.me.apana.org.au> <44E2CB10.9080701@garzik.org> <44E2DBF8.8040500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, kiran kandi <kkiran78@hotmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43275 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750777AbWHPKWl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 06:22:41 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <44E2DBF8.8040500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 01:48:56AM -0700, Ben Greear wrote:
>
> >>softirq
> 
> It can be process too...doesn't pktgen call it directly?

Only with BH disabled.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
