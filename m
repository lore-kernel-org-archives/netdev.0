From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/11 v2][pull request] Intel Wired LAN Driver
 Updates
Date: Thu, 13 Oct 2011 14:00:20 -0400 (EDT)
Message-ID: <20111013.140020.1488831185205140243.davem@davemloft.net>
References: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193Ab1JMSA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 14:00:26 -0400
In-Reply-To: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 Oct 2011 00:15:01 -0700

> The following series contains updates to ixgbe and igb.  This
> version of the series contains the following changes:
> 
> - ixgbe add FCoE stats, add protection from invalid DMA and fix
>   check for change in FCoE priority
> - igb version bump, fix sparse warnings and finish up the cleanup
>   work of igb by Alex Duyck.
> 
> - v2: drop the "igb: move DMA Coalescing feature code into separate function."
>   patch while Carolyn fixes the patch based on David Miller's comments.
> 
> The following are changes since commit 9687c637388f63b87fcc18eee6e65bcfca4f49ca:
>   Merge branch 'for-davem' of git://git.infradead.org/users/linville/wireless-next
> and are available in the git repository at
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

Pulled, thanks.
