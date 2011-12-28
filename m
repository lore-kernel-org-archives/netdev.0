From: David Miller <davem@davemloft.net>
Subject: Re: The mystery of optimistic ipv6 DAD handling
Date: Wed, 28 Dec 2011 13:39:33 -0500 (EST)
Message-ID: <20111228.133933.866545698956085305.davem@davemloft.net>
References: <20111227.140652.1729386263761283235.davem@davemloft.net>
	<20111227.145305.229364634255751368.davem@davemloft.net>
	<20111228151928.GA12025@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab1L1Sku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 13:40:50 -0500
In-Reply-To: <20111228151928.GA12025@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 28 Dec 2011 10:19:28 -0500

> Yeah, If the premise that the test never triggers is true (and it seems like
> you've confirmed that), then theres no harm in removing it.  It still
> seems like we might still need the test somewhere (maybe on a manual route add).
> I've family in town, so I'm not able to look at this closely today, but I'd say this
> is at least a harmless change right now.  Lets take this change, and I'll
> re-read the RFC and look for appropriate code paths where we may need this
> test in a few days.  Thanks Dave!
> 
> Acked-By: Neil Horman <nhorman@tuxdriver.com>

Thanks for reviewing Neil, I've applied this patch to net-next.
