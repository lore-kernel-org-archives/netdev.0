From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Wed, 04 Feb 2009 17:13:19 -0800 (PST)
Message-ID: <20090204.171319.20089712.davem@davemloft.net>
References: <E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au>
	<20090204.165630.95274793.davem@davemloft.net>
	<20090205010649.GA28046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756039AbZBEBNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 20:13:22 -0500
In-Reply-To: <20090205010649.GA28046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 5 Feb 2009 12:06:49 +1100

> On Wed, Feb 04, 2009 at 04:56:30PM -0800, David Miller wrote:
> > Please make this correction and resubmit.
> 
> Here we go.
> 
> tun: Limit amount of queued packets per device

I get tons of rejects in net-next-2.6, there were lots of
changes in this driver.

Don't even tell me you generate this against upstream of
net-2.6?  Tsk tsk :-)
