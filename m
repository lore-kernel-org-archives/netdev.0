From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: bcmsysport: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sun, 19 Jun 2016 16:20:26 -0700 (PDT)
Message-ID: <20160619.162026.268669845969549693.davem@davemloft.net>
References: <1466361549-6291-1-git-send-email-tremyfr@gmail.com>
	<1466361549-6291-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbcFSXU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 19:20:27 -0400
In-Reply-To: <1466361549-6291-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 19 Jun 2016 20:39:09 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
