From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Fix to parse RSS hash from Receive completions
 correctly.
Date: Thu, 26 Jul 2012 01:14:00 -0700 (PDT)
Message-ID: <20120726.011400.957707095049026104.davem@davemloft.net>
References: <2594050c-c887-436e-a6ba-01f7d804c03c@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab2GZIOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 04:14:08 -0400
In-Reply-To: <2594050c-c887-436e-a6ba-01f7d804c03c@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sarveshwar.bandi@emulex.com>
Date: Thu, 26 Jul 2012 12:59:50 +0530

> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> Wrong pointer variable is being used to parse the rss hash from
> receive completions leading to corrupted rss_hash values filled into skb.
> 
> Please apply to net.
  ^^^^^^^^^^^^^^^^^^^^

This doesn't belong in the commit message body, put it after the "---"
demarcation.

> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Applied, thanks.
