From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/2] amd-xgbe: AMD XGBE driver updates
 2014-11-06
Date: Thu, 06 Nov 2014 19:00:47 -0500 (EST)
Message-ID: <20141106.190047.1846700868326941068.davem@davemloft.net>
References: <20141106230207.21973.67338.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbaKGAAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 19:00:51 -0500
In-Reply-To: <20141106230207.21973.67338.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 6 Nov 2014 17:02:07 -0600

> The following series of patches fixes a couple of bugs that slipped
> through my last series.
> 
> - Free channel structure after freeing the per channel interrupts
> - If an skb error allocation occurs during receive processing check
>   whether more descriptors are associated with the packet or whether
>   to start on a new packet
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
