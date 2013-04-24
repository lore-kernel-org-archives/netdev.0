From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net/mlx4: Add support to SRIOV VF
 management ndo calls
Date: Wed, 24 Apr 2013 16:30:49 -0400 (EDT)
Message-ID: <20130424.163049.2212021825718596200.davem@davemloft.net>
References: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757600Ab3DXUaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 16:30:52 -0400
In-Reply-To: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 24 Apr 2013 19:41:08 +0300

> This series adds support for the SRIOV ndo_set_vf callbacks to the mlx4 driver.
> 
> Series done against the net-next tree as of commit 0c501345c "batman-adv: fix 
> global protection fault during soft_iface destruction".
> 
> We have successfully tested the series on net-next, except for getting
> the VF link info issue I have reported earlier today on netdev, we 
> see the problem for both ixgbe and mlx4 VFs. Just to make sure get 
> VF config is working OK with patch #6 - we have run it over 3.8.8 too.

Series applied, thanks.
