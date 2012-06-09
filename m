From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: fix drivers/net/phy/ kernel-doc warnings
Date: Fri, 08 Jun 2012 22:21:17 -0700 (PDT)
Message-ID: <20120608.222117.397187431024452846.davem@davemloft.net>
References: <4FD293B7.6080702@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab2FIFVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 01:21:17 -0400
In-Reply-To: <4FD293B7.6080702@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Fri, 08 Jun 2012 17:07:19 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix kernel-doc warnings in drivers/net/phy:
> 
> Warning(drivers/net/phy/mdio_bus.c:109): No description found for parameter 'mdio_bus_np'
> Warning(drivers/net/phy/mdio_bus.c:109): Excess function parameter 'mdio_np' description in 'of_mdio_find_bus'
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Applied.
