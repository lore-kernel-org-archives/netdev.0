From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Mon, 16 Jul 2012 23:04:43 -0700 (PDT)
Message-ID: <20120716.230443.678090938912359997.davem@davemloft.net>
References: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab2GQGEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:04:44 -0400
In-Reply-To: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 14 Jul 2012 16:06:58 -0700

> This series contains updates to e1000e and ixgbe.
> 
> The following are changes since commit 141e369de698f2e17bf716b83fcc647ddcb2220c:
>   xfrm: Initialize the struct xfrm_dst behind the dst_enty field
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Alexander Duyck (5):
>   ixgbe: Simplify logic for getting traffic class from user priority
>   ixgbe: Cleanup unpacking code for DCB
>   ixgbe: Populate the prio_tc_map in ixgbe_setup_tc
>   ixgbe: Add function for obtaining FCoE TC based on FCoE user priority
>   ixgbe: Merge FCoE set_num and cache_ring calls into RSS/DCB config
> 
> Matthew Vick (1):
>   e1000e: Program the correct register for ITR when using MSI-X.
> 
> Tushar Dave (1):
>   e1000e: Cleanup code logic in e1000_check_for_serdes_link_82571()

Pulled, thanks Jeff.
