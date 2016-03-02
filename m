From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Mellanox 10/40G mlx4 driver fixes for 4.5-rc6
Date: Wed, 02 Mar 2016 14:43:31 -0500 (EST)
Message-ID: <20160302.144331.333375037433773272.davem@davemloft.net>
References: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, majd@mellanox.com, yishaih@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbcCBTne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:43:34 -0500
In-Reply-To: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed,  2 Mar 2016 17:47:43 +0200

> This series contains two fixes for the SRIOV HW LAG that was 
> introduced in 4.5-rc1 and one fix that allows to revoke the 
> administrative MAC that was assigned to VF through the PF.
> 
> The VF mac fix needs to go for stable too.

Series applied and patch #3 queue up for -stable.
