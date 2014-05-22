From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: fec: correct the MDIO clock source
Date: Thu, 22 May 2014 15:03:33 -0400 (EDT)
Message-ID: <20140522.150333.115522030449629871.davem@davemloft.net>
References: <1400563389-3599-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbaEVTDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:03:34 -0400
In-Reply-To: <1400563389-3599-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 20 May 2014 13:23:09 +0800

> Since imx serials FEC/ENET MDIO clock source is internal ipg clock,
> and "ahb" clock is defined as FEC/ENET bus clock, so the patch just
> correct the fec driver MDIO clock source.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied to net-next.
