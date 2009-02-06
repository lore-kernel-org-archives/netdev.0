From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Thu, 05 Feb 2009 21:25:46 -0800 (PST)
Message-ID: <20090205.212546.195335800.davem@davemloft.net>
References: <20090205010649.GA28046@gondor.apana.org.au>
	<20090204.171319.20089712.davem@davemloft.net>
	<20090205032348.GA19181@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbZBFFZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 00:25:52 -0500
In-Reply-To: <20090205032348.GA19181@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 5 Feb 2009 14:23:48 +1100

> On Wed, Feb 04, 2009 at 05:13:19PM -0800, David Miller wrote:
> > 
> > I get tons of rejects in net-next-2.6, there were lots of
> > changes in this driver.
> > 
> > Don't even tell me you generate this against upstream of
> > net-2.6?  Tsk tsk :-)
> 
> How did you guess :)
> 
> Here is the rebased version.
> 
> tun: Limit amount of queued packets per device

Applied, thanks Herbert.
