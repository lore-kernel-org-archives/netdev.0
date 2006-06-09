From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Add netif_tx_lock
Date: Fri, 09 Jun 2006 12:21:22 -0700 (PDT)
Message-ID: <20060609.122122.123921143.davem@davemloft.net>
References: <20060601002525.GA19220@gondor.apana.org.au>
	<20060601111503.GA16097@gondor.apana.org.au>
	<20060609054816.GA7612@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7568
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030427AbWFITVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 15:21:21 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060609054816.GA7612@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 9 Jun 2006 15:48:16 +1000

> On Thu, Jun 01, 2006 at 09:15:03PM +1000, herbert wrote:
> > 
> > OK, here is a patch which does this.
> > 
> > [NET]: Add netif_tx_lock
> 
> Just noticed that I showed dyslexia in winbond.c :) Here is the corrected
> version.
> 
> [NET]: Add netif_tx_lock

:-)  Applied, thanks a lot Herbert.
