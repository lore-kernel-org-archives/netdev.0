From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Sat, 22 Sep 2012 15:39:22 -0400 (EDT)
Message-ID: <20120922.153922.821544789629097304.davem@davemloft.net>
References: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab2IVTjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:39:24 -0400
In-Reply-To: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 22 Sep 2012 03:30:29 -0700

> This series contains updates to igb only.
> 
> The following are changes since commit abb17e6c0c7b27693201dc85f75dbb184279fd10:
>   netlink: use <linux/export.h> instead of <linux/module.h>
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Alexander Duyck (5):
>   igb: Remove logic that was doing NUMA pseudo-aware allocations
>   igb: Change Tx cleanup loop to do/while instead of for
>   igb: Change how we populate the RSS indirection table
>   igb: Simplify how we populate the RSS key
>   igb: Use dma_unmap_addr and dma_unmap_len defines
> 
> Carolyn Wyborny (1):
>   igb: Fix stats output on i210/i211 parts.
> 
> Stefan Assmann (1):
>   igb: Change how we check for pre-existing and assigned VFs

Pulled, thanks Jeff.
