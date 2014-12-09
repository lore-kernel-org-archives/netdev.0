From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 0/2] amd-xgbe: AMD XGBE driver fixes 2014-12-02
Date: Tue, 09 Dec 2014 13:16:12 -0500 (EST)
Message-ID: <20141209.131612.1789803557119310906.davem@davemloft.net>
References: <20141203001642.17582.32777.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbaLISQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:16:15 -0500
In-Reply-To: <20141203001642.17582.32777.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 2 Dec 2014 18:16:42 -0600

> The following series of patches includes two bug fixes. Unfortunately,
> the first patch will create a conflict when eventually merged into
> net-next but should be very easy to resolve.
> 
> - Do not clear the interrupt bit in the xgbe_ring_data structure
> - Associate a Tx SKB with the proper xgbe_ring_data structure
> 
> This patch series is based on net.

Series applied, thanks Tom.
