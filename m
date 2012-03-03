From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Sat, 03 Mar 2012 14:53:00 -0500 (EST)
Message-ID: <20120303.145300.2270021306522965487.davem@davemloft.net>
References: <1330741587-24073-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992Ab2CCTzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 14:55:04 -0500
In-Reply-To: <1330741587-24073-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  2 Mar 2012 18:26:23 -0800

> This series of patches contains fixes e100 and DCB (ixgbe, bnx2x).
> 
> The following are changes since commit b4017c5368f992fb8fb3a2545a0977082c6664e4:
>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Ben Greear (2):
>   e100: Fix rx-over-length statistics.
>   e100: Show short v/s long rx length errors in ethtool stats.
> 
> John Fastabend (2):
>   ixgbe: dcb: check setup_tc return codes
>   net: dcb: getnumtcs()/setnumtcs() should return an int

Pulled, thanks.
