From: David Miller <davem@davemloft.net>
Subject: Re: [net:master 114/121] drivers/net/phy/mdio_bus.c:248: warning:
 No description found for parameter 'owner'
Date: Fri, 25 Sep 2015 21:37:44 -0700 (PDT)
Message-ID: <20150925.213744.2117695928443852915.davem@davemloft.net>
References: <201509251554.GLQ5oOz9%fengguang.wu@intel.com>
	<20150925105656.GK21513@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, kbuild-all@01.org, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbbIZEhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 00:37:48 -0400
In-Reply-To: <20150925105656.GK21513@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Fri, 25 Sep 2015 11:56:56 +0100

> From: Russell King <rmk+kernel@arm.linux.org.uk>
> Subject: [PATCH] net: update docbook comment for __mdiobus_register()
> 
> Update the docbook comment for __mdiobus_register() to include the new
> module owner argument.  This resolves a warning found by the 0-day
> builder.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied, thanks.
