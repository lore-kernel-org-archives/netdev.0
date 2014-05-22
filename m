From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/2] net/mlx4_core: Deprecate module
 parameter use_prio
Date: Thu, 22 May 2014 17:17:56 -0400 (EDT)
Message-ID: <20140522.171756.2050303950456581895.davem@davemloft.net>
References: <1400763340-15028-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaEVVR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 17:17:58 -0400
In-Reply-To: <1400763340-15028-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 22 May 2014 15:55:38 +0300

> This small patchset deprecates the mlx4_core module paramater 'use_prio', as
> suggested by Carol Soto from IBM in [1].
> Also, replaced some calls to the prefered pr_warn/info/devel macro's.
> 
> Patchset was applied and tested on commit b6052af: "Merge tag
> 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge"
> 
> [1] - http://marc.info/?l=linux-netdev&m=139871350103432&w=2
> 
> Changes from V0:
> - Patch 1/2: Deprecate use_prio module parameter
>   - Commit message was confusing and not accurate, rewrote it

Ok, fair enough, applied to net-next thanks.
