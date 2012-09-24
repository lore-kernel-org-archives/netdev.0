From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Mon, 24 Sep 2012 13:48:23 -0400 (EDT)
Message-ID: <20120924.134823.832908439524408411.davem@davemloft.net>
References: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757234Ab2IXRsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 13:48:25 -0400
In-Reply-To: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 24 Sep 2012 02:00:01 -0700

> This series contains updates to ixgbe and ixgbevf (mainly ixgbevf).
> 
> The following are changes since commit c9d2ea96ca3bbc85264803ff6bd66eb3bbefdb77:
>   netlink: Rearrange netlink_kernel_cfg to save space on 64-bit.
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Alexander Duyck (3):
>   ixgbevf: Fix code for handling timeout
>   ixgbevf: Add fix to VF to handle multi-descriptor buffers
>   ixgbevf: Return error on failure to enable VLAN
> 
> Greg Rose (2):
>   ixgbe: Do not read the spoofed packets counter when not in IOV mode
>   ixgbevf: Fix AIM (Adaptive Interrupt Moderation)
> 
> Narendra K (1):
>   ixgbevf - Remove unused parameter in ixgbevf_receive_skb

Pulled, thanks Jeff.
