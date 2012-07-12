From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/5][pull request] Intel Wired LAN Driver Updates
Date: Thu, 12 Jul 2012 08:01:51 -0700 (PDT)
Message-ID: <20120712.080151.1332556758955607558.davem@davemloft.net>
References: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932528Ab2GLPBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 11:01:52 -0400
In-Reply-To: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 11 Jul 2012 02:09:24 -0700

> This series contains updates to ixgbe.
> 
> The following are changes since commit 4715213d9cf40285492fff4092bb1fa8e982f632:
>   bridge: fix endian
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Alexander Duyck (5):
>   ixgbe: count q_vectors instead of MSI-X vectors
>   ixgbe: Add upper limit to ring features
>   ixgbe: Add feature offset value to ring features
>   ixgbe: Clean up a useless switch statement and dead code in
>     configure_srrctl
>   ixgbe: Merge RSS and flow director ring register caching and
>     configuration

Pulled, thanks Jeff.
