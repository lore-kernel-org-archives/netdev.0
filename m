From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] note that NETIF_F_LLTX is deprecated
Date: Tue, 25 Sep 2007 19:42:25 -0700 (PDT)
Message-ID: <20070925.194225.102140601.davem@davemloft.net>
References: <20070921140833.GA12242@gondor.apana.org.au>
	<200709211659.54935.borntraeger@de.ibm.com>
	<20070922005709.GA17022@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: borntraeger@de.ibm.com, jeff@garzik.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34267
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754509AbXIZCm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 22:42:26 -0400
In-Reply-To: <20070922005709.GA17022@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 22 Sep 2007 08:57:10 +0800

> On Fri, Sep 21, 2007 at 04:59:54PM +0200, Christian Borntraeger wrote:
> > 
> > I suggest to document that LLTX is deprecated. 
> > 
> > Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> 
> This looks good to me.

To me too, applied to net-2.6.24, thanks.
