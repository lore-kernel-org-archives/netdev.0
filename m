From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Wed, 20 Jun 2012 15:09:27 -0700 (PDT)
Message-ID: <20120620.150927.1036845581501436783.davem@davemloft.net>
References: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754835Ab2FTWJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 18:09:30 -0400
In-Reply-To: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 20 Jun 2012 01:44:39 -0700

> This series contains fixes to igb, ixgbe and intel/Kconfig
> 
> The following are changes since commit 2c995ff892313009e336ecc8ec3411022f5b1c39:
>   batman-adv: fix skb->data assignment
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master
> 
> Alexander Duyck (1):
>   ixgbe: Fix memory leak in ixgbe when receiving traffic on DDP enabled
>     rings
> 
> Carolyn Wyborny (2):
>   igb: Fix incorrect RAR address entries for i210/i211 device.
>   Kconfig: Fix Kconfig for Intel ixgbe and igb PTP support.

Pulled, thanks Jeff.
