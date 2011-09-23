From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/8 v2][pull request] Intel Wired LAN Driver Updates
Date: Fri, 23 Sep 2011 13:57:07 -0400 (EDT)
Message-ID: <20110923.135707.555070140565509860.davem@davemloft.net>
References: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127Ab1IWR5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 13:57:10 -0400
In-Reply-To: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 23 Sep 2011 09:12:39 -0700

> The following series contains updates to ixgbe and PCI.  The PCI patch
> is a small update to add a flag to indicate when a device has been
> assigned by KVM.  The ixgbe patches consist of the following:
> 
>   - reconfigure SR-IOV init to take advantage of the new pci flag
>   - DCB cleanups/fixes
>   - add WOL support for x540
>   - a few cleanup/fixes
> 
>  -v2 Fixed up comment in the PCI patch based on feedback from Ian Campbell
> 
> The following are changes since commit 9c9b1f24f2aa31a3cea94939edc551f68ebadc89:
>   net/phy: add IC+ IP101A and support APS.
> and are available in the git repository at:
>   git://github.com/Jkirsher/net-next.git

Pulled, thanks Jeff.
