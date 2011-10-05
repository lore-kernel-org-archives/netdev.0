From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/10 v3][pull request] Intel Wired LAN Driver
 Updates
Date: Wed, 05 Oct 2011 16:44:41 -0400 (EDT)
Message-ID: <20111005.164441.2062104241833324241.davem@davemloft.net>
References: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674Ab1JEUoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 16:44:55 -0400
In-Reply-To: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  5 Oct 2011 03:20:14 -0700

> The following series contains updates to e1000e and ixgbe. The one
> patch for e1000e makes function tables const, thanks to Stephen
> Hemminger for reporting this.  The remaining patches are for ixgbe,
> and the contain the following:
> 
>  - minor cleanups
>  - add support for 82599 device and ethtool -E support
>  - removal of a PHY which is not used in production silicon
> 
> v2- Updated patch 11 with the suggested changes from Ben Hutchings
> v3- Drop patch 11 so that Emil can re-work the patch based on feedback
> 
> The following are changes since commit 70f14381299984f05764c3188f1706288285c953:
>   bna: Multiple Definition and Interface Setup Fix
> and are available in the git repository at
>   git://github.com/Jkirsher/net-next.git

Pulled, thanks Jeff.
