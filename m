From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] be2net fixes
Date: Wed, 02 May 2012 21:07:40 -0400 (EDT)
Message-ID: <20120502.210740.328667962599363816.davem@davemloft.net>
References: <88a38ad8-0db5-47cb-a868-59e13a8f746d@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152Ab2ECBHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 21:07:44 -0400
In-Reply-To: <88a38ad8-0db5-47cb-a868-59e13a8f746d@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Wed, 2 May 2012 19:09:46 +0530

> Re-posting patches 1-4 from the earlier patch set of 5.
> Incorporated review comment from Ben Hutchings in patch 2.
> Will address comments in Patch 5 and send it out seperately.
> 
> Somnath Kotur (4):
>   be2net: Fix to not set link speed for disabled functions of a UMC
>     card
>   be2net: Fix to apply duplex value as unknown when link is down.
>   be2net: Record receive queue index in skb to aid RPS.
>   be2net: Fix EEH error reset before a flash dump completes

All applied, thanks.
