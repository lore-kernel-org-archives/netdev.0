From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: re-add IFF_UNICAST_FLT for dwmac1000
Date: Wed, 04 Apr 2012 18:38:53 -0400 (EDT)
Message-ID: <20120404.183853.2043289712785677775.davem@davemloft.net>
References: <1333527181-17279-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757050Ab2DDWkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:40:04 -0400
In-Reply-To: <1333527181-17279-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed,  4 Apr 2012 10:13:01 +0200

> In commit (bfab27a stmmac: add the experimental PCI support) the
> IFF_UNICAST_FLT flag has been removed from the stmmac_mac_device_setup()
> function. This patch re-adds the flag.
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
