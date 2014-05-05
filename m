From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net 0/4] Batch of fixes for 3.15
Date: Mon, 05 May 2014 15:50:28 -0400 (EDT)
Message-ID: <20140505.155028.2090701658184639551.davem@davemloft.net>
References: <1399212445-5070-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, matanb@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbaEETub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 15:50:31 -0400
In-Reply-To: <1399212445-5070-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  4 May 2014 17:07:21 +0300

> This series contains fixes for 3.15-rc, mostly around SRIOV. The patches by Jack,
> Matan and myself fix few issues related to mlx4 SRIOV support for RoCE and single 
> port VFs, and the patch from Eyal eliminates checking PCI caps for VFs which is misleading.
> 
> Patches done against the net tree, commit 014f1b2 "net: bonding: Fix format string 
> mismatch in bond_sysfs.c"
> 
> We'd be happy to get Eyal's patch queued in your -stable list for 3.14.y

All applied, and patch #4 queued up for -stable, thanks.
