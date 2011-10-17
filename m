From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/5 v2][pull request] Intel Wired LAN Driver Updates
Date: Sun, 16 Oct 2011 21:57:46 -0400 (EDT)
Message-ID: <20111016.215746.198596742781214060.davem@davemloft.net>
References: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab1JQB5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 21:57:51 -0400
In-Reply-To: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 16 Oct 2011 13:36:58 -0700

> The following series contains updates to e1000e, if_link, ixgbe, igbvf
> and igb.  This version of the series contains the following changes:
> 
> - e1000e not sure what happened in the pull on Tuesday which has this fix
>   so re-posting this fix
> - igb enable L4 timestamping
> - igbvf final conversion to ndo_fix_features
> - if_link/ixgbe add spoof checking feature
> 
> -v2 drop the igb fix for timecompare_update
> 
> The following are changes since commit 96cd8951684adaa5fd72952adef532d0b42f70e1:
>   ftmac100: fix skb truesize underestimation
> and are available in the git repository at
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

Pulled, thanks Jeff.
