From: David Miller <davem@davemloft.net>
Subject: Re: [net v2 0/6][pull request] Intel Wired LAN Driver Updates
Date: Fri, 27 Sep 2013 13:29:26 -0400 (EDT)
Message-ID: <20130927.132926.397457416231095557.davem@davemloft.net>
References: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892Ab3I0R3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 13:29:30 -0400
In-Reply-To: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 27 Sep 2013 05:35:52 -0700

> This series contains updates to igb and i40e.
> 
> Todd provides a fix for 82580 devices in igb, where the ethtool
> loopback test was missing 82580 copper devices.
> 
> Jesse provides five fixes/cleanups to i40e based on feedback from
> Joe Perches and the community.
> 
> v2: fixed up patch 5 in the series based on feedback from Joe Perches
>     and David Miller
> 
> The following are changes since commit f875691640cd3fa67f7ad1d3130ff9fa7fdca042:
>   Merge branch 'fixes-for-3.12' of git://gitorious.org/linux-can/linux-can
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Pulled, thanks a lot Jeff.
