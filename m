From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 0/3] Mellanox Core and Ethernet driver
 updates 2013-04-07
Date: Sun, 07 Apr 2013 16:56:00 -0400 (EDT)
Message-ID: <20130407.165600.2149035281450422147.davem@davemloft.net>
References: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, sagig@mellanox.com,
	john.r.fastabend@intel.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934334Ab3DGU4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 16:56:02 -0400
In-Reply-To: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  7 Apr 2013 16:44:05 +0300

> Hi Dave,
> 
> Here's V1 of this batch of mlx4 driver updates for 3.10, mostly DCB related. 
> 
> Series done against the net-next tree as of commit a210576c "Merge 
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net"
> 
> changes from V0: 
> 
>   - in patch #2 advertize getdcbx/setdcbx callbacks also for devices that support only PFC
> 
>   - per feedback from John, dropeed patch #3 which turned to be work-around for user space 
>     bug in open-lldp. John posted a user space patch to fix the bug
> 
>   - per feedback from John, added small a patch under which we advertize DCB_CAP_DCBX_HOST in getdcbx

All applied, thanks.
