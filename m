From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc5 with GRE, iptables and Speedtouch ADSL, PPP over ATM
Date: Mon, 18 Sep 2006 00:22:56 -0700 (PDT)
Message-ID: <20060918.002256.31639200.davem@davemloft.net>
References: <m3odty57gf.fsf@defiant.localdomain>
	<20060903111507.GA12580@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7359
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751278AbWIRHXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:23:08 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060903111507.GA12580@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 3 Sep 2006 21:15:07 +1000

> So here is a simple patch to remove the tx lock from dev_watchdog_up.
> In 2.6.19 we can eliminate the unnecessary __dev_watchdog_up and
> replace it with dev_watchdog_up.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
