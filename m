From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/7][pull request] Intel Wired LAN Driver Updates
Date: Fri, 10 Feb 2012 15:11:21 -0500 (EST)
Message-ID: <20120210.151121.2190508003245555755.davem@davemloft.net>
References: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760044Ab2BJUL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 15:11:26 -0500
In-Reply-To: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Feb 2012 00:08:50 -0800

> The following series contains updates to igb and e1000e.
> Majority of the updates are to e1000e and do the following:
>  - several cleanups which remove unnecessary () and returns from void
>    functions
>  - remove test that is always false
>  - use 'true' instead of '1' for boolean
> The one igb fix resolves warning about unused function.
> 
> v2- updated patch 4 based on feedback from community
> 
> The following are changes since commit 4cbbb04dc115423682349aa7466c8aeead825140:
>   cnic: Update VLAN ID during ISCSI_UEVENT_PATH_UPDATE
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
