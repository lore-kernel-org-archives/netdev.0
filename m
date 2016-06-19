From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: nb8800: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sun, 19 Jun 2016 10:55:54 -0700 (PDT)
Message-ID: <20160619.105554.1260164113908056617.davem@davemloft.net>
References: <1466284615-7045-1-git-send-email-tremyfr@gmail.com>
	<1466284615-7045-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mans@mansr.com, sf84@laposte.net, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbcFSRzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 13:55:55 -0400
In-Reply-To: <1466284615-7045-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 18 Jun 2016 23:16:55 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
