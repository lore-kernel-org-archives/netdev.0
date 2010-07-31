From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Allow multicast snooping to be disabled before ifup
Date: Fri, 30 Jul 2010 23:37:34 -0700 (PDT)
Message-ID: <20100730.233734.246534269.davem@davemloft.net>
References: <20100729104529.GA29678@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46754
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755340Ab0GaGhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:37:16 -0400
In-Reply-To: <20100729104529.GA29678@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 29 Jul 2010 18:45:30 +0800

> bridge: Allow multicast snooping to be disabled before ifup
> 
> Currently you cannot disable multicast snooping while a device is
> down.  There is no good reason for this restriction and this patch
> removes it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'll apply this to net-next-2.6, thanks Herbert.
