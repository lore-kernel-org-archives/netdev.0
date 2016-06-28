From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: r6040: use
 phy_ethtool_{get|set}_link_ksettings
Date: Tue, 28 Jun 2016 09:15:46 -0400 (EDT)
Message-ID: <20160628.091546.1020578161152286724.davem@davemloft.net>
References: <1466881742-13414-1-git-send-email-tremyfr@gmail.com>
	<1466881742-13414-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbcF1NQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:16:27 -0400
In-Reply-To: <1466881742-13414-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 25 Jun 2016 21:09:02 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
