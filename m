From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Tue, 09 Oct 2012 12:51:11 -0400 (EDT)
Message-ID: <20121009.125111.920009127542243278.davem@davemloft.net>
References: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab2JIQvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 12:51:13 -0400
In-Reply-To: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  9 Oct 2012 03:13:29 -0700

> This series contains updates to ixgbe, ixgbevf and e1000e.
> 
> The following are changes since commit 66eef59f22275002f621ff9d951886b513d011b3:
>   net: fix typo in freescale/ucc_geth.c
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master
> 
> Alexander Duyck (1):
>   ixgbe/ixgbevf: Limit maximum jumbo frame size to 9.5K to avoid Tx
>     hangs
> 
> Bruce Allan (1):
>   e1000e: add device IDs for i218
> 
> Greg Rose (1):
>   ixgbevf: Set the netdev number of Tx queues

Pulled but please let's get that multi-month-old e1000e BQL bug fixed.

Thanks.
