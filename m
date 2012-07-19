From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 19 Jul 2012 08:26:38 -0700 (PDT)
Message-ID: <20120719.082638.521975628870200319.davem@davemloft.net>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab2GSP0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:26:46 -0400
In-Reply-To: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 18 Jul 2012 13:31:47 -0700

> This series contains updates to ixgbevf & ixgbe.
> 
> The following are changes since commit ddbe503203855939946430e39bae58de11b70b69:
>   ipv6: add ipv6_addr_hash() helper
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Alexander Duyck (8):
>   ixgbevf: Do not rewind the Rx ring before bumping tail
>   ixgbevf: Add netdev to ring structure
>   ixgbevf: Consolidate Tx context descriptor creation code
>   ixgbevf: Fix multiple issues in ixgbevf_get/set_ringparam
>   ixgbe: Update configure virtualization to allow for multiple PF pools
>   ixgbe: Add support for SR-IOV w/ DCB or RSS
>   ixgbe: Retire RSS enabled and capable flags
>   ixgbe: Cleanup holes in flags after removing several of them
> 
> Pascal Bouchareine (1):
>   ixgbevf: fix VF untagging when 802.1 prio is set

Pulled, thanks Jeff.
