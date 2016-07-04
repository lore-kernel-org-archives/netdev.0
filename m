From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: arc: emac: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 04 Jul 2016 16:00:38 -0700 (PDT)
Message-ID: <20160704.160038.1573698546151080630.davem@davemloft.net>
References: <1467482812-13917-1-git-send-email-tremyfr@gmail.com>
	<1467482812-13917-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wxt@rock-chips.com, heiko@sntech.de, al.kochet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:50948 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753803AbcGDXAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 19:00:40 -0400
In-Reply-To: <1467482812-13917-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  2 Jul 2016 20:06:52 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
