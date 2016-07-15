From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: xilinx: axienet: use
 phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 16:43:22 -0700 (PDT)
Message-ID: <20160715.164322.1968963296180277238.davem@davemloft.net>
References: <1468518358-28735-1-git-send-email-tremyfr@gmail.com>
	<1468518358-28735-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56516 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbcGOXnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:43:23 -0400
In-Reply-To: <1468518358-28735-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 14 Jul 2016 19:45:58 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
