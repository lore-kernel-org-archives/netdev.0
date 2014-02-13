From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: core: introduce netif_skb_dev_features
Date: Thu, 13 Feb 2014 17:17:32 -0500 (EST)
Message-ID: <20140213.171732.1373508730100061804.davem@davemloft.net>
References: <1392329352-31606-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbaBMWRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:17:34 -0500
In-Reply-To: <1392329352-31606-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 13 Feb 2014 23:09:11 +0100

> Will be used by upcoming ipv4 forward path change that needs to
> determine feature mask using skb->dst->dev instead of skb->dev.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable.
