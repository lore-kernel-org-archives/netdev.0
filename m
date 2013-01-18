From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc: smc911x: Fix sparse warnings
Date: Fri, 18 Jan 2013 14:33:17 -0500 (EST)
Message-ID: <20130118.143317.2037607950131769313.davem@davemloft.net>
References: <1358477163-7582-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:33:19 -0500
In-Reply-To: <1358477163-7582-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Fri, 18 Jan 2013 00:46:02 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> ioremap returns 'void __iomem *' type.
> 
> Fix the following build warnings:
 ...
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied to net-next, thanks.
