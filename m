From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: pasemi_mac: use
 phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 16:43:31 -0700 (PDT)
Message-ID: <20160715.164331.1985728517222674996.davem@davemloft.net>
References: <1468532693-456-1-git-send-email-tremyfr@gmail.com>
	<1468532693-456-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbcGOXnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:43:33 -0400
In-Reply-To: <1468532693-456-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 14 Jul 2016 23:44:53 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
