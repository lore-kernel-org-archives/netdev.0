From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 06 Oct 2011 14:33:50 -0400 (EDT)
Message-ID: <20111006.143350.1218857772271381910.davem@davemloft.net>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758915Ab1JFSeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 14:34:02 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  6 Oct 2011 04:02:30 -0700

> The following series contains updates to e1000e, igb and ixgbe.  Here
> is a quick summary:
>   - e1000e: fixes for 2 WoL issues
>   - igb: fix for I2C, and 2 Alt. MAC address updates
>   - ixgbe: fix dependencies for 8 traffic classes, add X540 traffic
>     class support and a fix for PFC mask generation
> 
> The following are changes since commit f0cd7bdc042310b6b104f133bbfd520a72b3c08a:
>   bnx2x: remove some dead code
> and are available in the git repository at
>   git://github.com/Jkirsher/net-next.git

Pulled, thanks Jeff.
