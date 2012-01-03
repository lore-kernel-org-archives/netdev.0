From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Tue, 03 Jan 2012 12:23:34 -0500 (EST)
Message-ID: <20120103.122334.326551836776966296.davem@davemloft.net>
References: <1325555451-4697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179Ab2ACRXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 12:23:40 -0500
In-Reply-To: <1325555451-4697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  2 Jan 2012 17:50:44 -0800

> The following series contains updates to igb, ixgbe and ixgbevf.  Most of
> the changes are adding support of some kind.  There are 3 fixes, one fix
> for ixgbevf to fix register defines.  The other two fixes are for ixgbe,
> one being a minor comment spelling fix and the other is to fix register
> reads.
> 
> Here is a list of the new support added:
>  - 2 new device id's in ixgbe
>  - igb flow control advertising to ethtool
> 
> v2: Dropped the 2 patches to 'add thermal data sensor' to ixgbe while Don/PJ
>     review and potentially fix-up the patches based on community feedback.
> 
> The following are changes since commit 455ffa607f0efa90c9fec99604553b7cdd5274b2:
>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
