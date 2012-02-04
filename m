From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/7][pull request] Intel Wired LAN Driver Update
Date: Sat, 04 Feb 2012 15:54:42 -0500 (EST)
Message-ID: <20120204.155442.1648336318117828618.davem@davemloft.net>
References: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab2BDUyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 15:54:45 -0500
In-Reply-To: <1328267703-9638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  3 Feb 2012 03:14:56 -0800

> v2- Dropped the ixgbe namespace fix patch to find a better resolution
>     based on feedback from David Miller.
> 
> The following are changes since commit 29830406415c227a54af429d7b300aabd4754237:
>   can: peak_pci: Fix the way channels are linked together
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

These are "fixes" and based upon my "net" tree, but your subject lines
say "net-next"...

I know you meant "net" but...
