From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/8][pull request] Intel Wired LAN Driver Updates
Date: Thu, 05 Jan 2012 13:12:20 -0500 (EST)
Message-ID: <20120105.131220.1405518713871944734.davem@davemloft.net>
References: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab2AESM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:12:28 -0500
In-Reply-To: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  4 Jan 2012 22:23:32 -0800

> The following series contains updates to e1000, igb and
> netdev/ixgbe.  There are 2 fixes and the remaining patches are
> either add support or cleanup.
> 
> Here is a list of the new support added:
>  - igb adds support for byte queue limits and basic runtime PM
>  - FCoE adds ndo_get_fcoe_hbainfo() call
> 
> v2- Dropped e1000e patches while Bruce works on the suggested changes and
>     added 2 e1000 patches from Florian.
> 
> The following are changes since commit 117ff42fd43e92d24c6aa6f3e4f0f1e1edada140:
>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
