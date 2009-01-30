From: David Miller <davem@davemloft.net>
Subject: Re: [0/4] GRO optimisations
Date: Thu, 29 Jan 2009 16:54:19 -0800 (PST)
Message-ID: <20090129.165419.104743020.davem@davemloft.net>
References: <20090130001849.GA1272@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44703
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754201AbZA3AyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:54:21 -0500
In-Reply-To: <20090130001849.GA1272@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jan 2009 11:18:49 +1100

> This is a dump of my current patches to optimise GRO in order
> to get cxgb3 performance back up to the LRO level.  I've got
> some more ideas but I'd like to get this out first so it doesn't
> rot in my tree.

All applied to net-next-2.6, thanks Herbert!
