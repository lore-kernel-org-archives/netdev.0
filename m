From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29.1 pktgen crash
Date: Thu, 21 May 2009 15:07:34 -0700 (PDT)
Message-ID: <20090521.150734.87902921.davem@davemloft.net>
References: <20090520202450.GA12896@francoudi.com>
	<20090521215915.GA32737@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hazard@francoudi.com, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754887AbZEUWHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 18:07:36 -0400
In-Reply-To: <20090521215915.GA32737@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 21 May 2009 23:59:15 +0200

> pktgen: do not access flows[] beyond its length
> 
> typo -- pkt_dev->nflows is for stats only, the number of concurrent
> flows is stored in cflows.
> 
> Reported-By: Vladimir Ivashchenko <hazard@francoudi.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks.
