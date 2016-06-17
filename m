From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: ax88796: use
 phy_ethtool_{get|set}_link_ksettings
Date: Thu, 16 Jun 2016 17:07:34 -0700 (PDT)
Message-ID: <20160616.170734.2254143292941364542.davem@davemloft.net>
References: <1466028769-27866-1-git-send-email-tremyfr@gmail.com>
	<1466028769-27866-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbcFQAHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 20:07:35 -0400
In-Reply-To: <1466028769-27866-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 16 Jun 2016 00:12:49 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
