From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 00/13][pull request] Intel Wired LAN Driver
 Update
Date: Sun, 15 May 2011 01:21:08 -0400 (EDT)
Message-ID: <20110515.012108.15947576632987708.davem@davemloft.net>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab1EOFVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 01:21:17 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 14 May 2011 18:23:34 -0700

> The following series contains updates to e1000e, ixgbevf and ixgbe.
> 
> -e1000e: minor comment fix
> -ixgbevf: add support for macvlan
> -ixgbe: mostly cleanup with the addition of support for a new adapter
> 
> The following are changes since commit 7be799a70ba3dd90a59e8d2c72bbe06020005b3f:
>   ipv4: Remove rt->rt_dst reference from ip_forward_options()
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Pulled, thanks Jeff.

How are the ethtool op conversions coming so I can apply the patch from
Marius that deletes the deprecated ones?

Thanks.
