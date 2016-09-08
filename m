From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] Mellanox 100G mlx5 fixes 2016-09-07
Date: Thu, 08 Sep 2016 16:16:20 -0700 (PDT)
Message-ID: <20160908.161620.794421565220428890.davem@davemloft.net>
References: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753204AbcIHXQV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 19:16:21 -0400
In-Reply-To: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed,  7 Sep 2016 19:07:56 +0300

> The following series contains bug fixes for the mlx5e driver.
> 
> from Gal,
> 	- Static code checker cleanup (casting overflow)
> 	- Fix global PFC counter statistics reading
> 	- Fix HW LRO when vlan stripping is off
> 
> From Bodong,
> 	- Deprecate old autoneg capability bit and use new one.
> 
> From Tariq,
> 	- Fix xmit more counter race condition

Series applied, thanks.


> For -stable:
> ('net/mlx5e: Fix parsing of vlan packets when updating lro header')

Queued up.
