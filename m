From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Fri, 07 Oct 2011 12:38:34 -0400 (EDT)
Message-ID: <20111007.123834.2034620343016383730.davem@davemloft.net>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965487Ab1JGQiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 12:38:46 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  7 Oct 2011 00:18:32 -0700

> The following series contains updates to e1000, e1000e, igb and ixgbe.  Here
> is a quick summary:
>   - e1000: 3 conversions (timers->threads, mdelay->msleep, mutex->rtnl)
>   - e1000e: fix jumbo frames on 82579
>   - igb: several cleanups to reduce stack space and improve performance
>   - ixgbe: bump driver ver
> 
> The following are changes since commit e878d78b9a7403fabc89ecc93c56928b74d14f01:
>   virtio-net: Verify page list size before fitting into skb
> and are available in the git repository at
>   git://github.com/Jkirsher/net-next.git

Pulled, thanks Jeff.
