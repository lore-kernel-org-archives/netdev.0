From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh-eth: Fix build error by the value which is not
 defined
Date: Tue, 17 Jan 2012 10:31:54 -0500 (EST)
Message-ID: <20120117.103154.2166245321090691814.davem@davemloft.net>
References: <1326768616-14182-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, florian@openwrt.org
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547Ab2AQPcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:32:05 -0500
In-Reply-To: <1326768616-14182-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Tue, 17 Jan 2012 11:50:16 +0900

> -----
> drivers/net/ethernet/renesas/sh_eth.c:1706: error: 'pdid' undeclared (first use in this function)
> drivers/net/ethernet/renesas/sh_eth.c:1706: error: (Each undeclared identifier is reported only once
> drivers/net/ethernet/renesas/sh_eth.c:1706: error: for each function it appears in.)
> make[5]: *** [drivers/net/ethernet/renesas/sh_eth.o] Error 1
> -----
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> CC: Florian Fainelli <florian@openwrt.org>

Applied.
