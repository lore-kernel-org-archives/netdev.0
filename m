From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/fec: Add Vybrid family fec support
Date: Fri, 12 Apr 2013 18:26:12 -0400 (EDT)
Message-ID: <20130412.182612.1613373240725639505.davem@davemloft.net>
References: <1365750765-3615-1-git-send-email-b35083@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	shawn.guo@linaro.org
To: b35083@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3DLW0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 18:26:14 -0400
In-Reply-To: <1365750765-3615-1-git-send-email-b35083@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingchang Lu <b35083@freescale.com>
Date: Fri, 12 Apr 2013 15:12:45 +0800

> Freescale Vybrid platform implentments MAC-ENET core
> providing compatibility with half- or full-duplex
> 10/100 Mbit/s Ethernet LANs.
> 
> Signed-off-by: Jingchang Lu <b35083@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.c | 5 +++++

Applied, but the driver source file is now named:

	drivers/net/ethernet/freescale/fec_main.c

in net-next, so I had to edit your patch.
