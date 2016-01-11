From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lpc_eth: Remove unused variables
Date: Sun, 10 Jan 2016 22:50:39 -0500 (EST)
Message-ID: <20160110.225039.2064304439956552184.davem@davemloft.net>
References: <1452255556-21827-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org, fabio.estevam@nxp.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757937AbcAKDul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 22:50:41 -0500
In-Reply-To: <1452255556-21827-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Fri,  8 Jan 2016 10:19:16 -0200

> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Commit e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
> introduced the following build warnings:
> 
> drivers/net/ethernet/nxp/lpc_eth.c: In function 'lpc_mii_init':
> drivers/net/ethernet/nxp/lpc_eth.c:865:1: warning: label 'err_out_1' defined but not used [-Wunused-label]
> drivers/net/ethernet/nxp/lpc_eth.c:826:20: warning: unused variable 'i' [-Wunused-variable]
> 
> Remove the unused variables to fix them.
> 
> Reported-by: Olof's autobuilder <build@lixom.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Applied, thanks Fabio.
