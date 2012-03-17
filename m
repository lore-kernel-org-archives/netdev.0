From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Sat, 17 Mar 2012 02:06:51 -0700 (PDT)
Message-ID: <20120317.020651.542839393490226567.davem@davemloft.net>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760Ab2CQJGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 05:06:55 -0400
In-Reply-To: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 17 Mar 2012 01:50:48 -0700

> This series of patches contains additions/cleanups to igb and ixgbe.
> There 2 patches for igb & ixgbe which add FX-ALL feature flag and
> sending of custom Ethernet FCS from Ben Greear.
> 
> The remaining patches in the series is part three of three to update
> ixgbe.  Although it looks like there will be at least one follow on
> patch series complete the update/cleanup of ixgbe.
> 
> The following are changes since commit 126a3fd251b244eabd9ab9dcb32b8b6f999c1b91:
>   eni: fix driver remove function and driver probe error path.
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
