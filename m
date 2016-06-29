From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: lpc_eth: use
 phy_ethtool_{get|set}_link_ksettings
Date: Wed, 29 Jun 2016 08:19:03 -0400 (EDT)
Message-ID: <20160629.081903.1209115201246381107.davem@davemloft.net>
References: <1467151185-31403-1-git-send-email-tremyfr@gmail.com>
	<1467151185-31403-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vz@mleia.com, slemieux.tyco@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114AbcF2MTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 08:19:33 -0400
In-Reply-To: <1467151185-31403-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 28 Jun 2016 23:59:45 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
