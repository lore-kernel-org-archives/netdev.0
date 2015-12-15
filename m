From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 0/4] stmmac: create of compatible mdio bus for
 stmacc driver
Date: Tue, 15 Dec 2015 00:28:52 -0500 (EST)
Message-ID: <20151215.002852.426273016037598426.davem@davemloft.net>
References: <1450063922-19481-1-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, vbridger@opensource.altera.com,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
To: preid@electromag.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbLOF2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 00:28:55 -0500
In-Reply-To: <1450063922-19481-1-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Reid <preid@electromag.com.au>
Date: Mon, 14 Dec 2015 11:31:58 +0800

> Provide ability to specify a fixed phy in the device tree and
> retain the mdio bus if no phy is found. This is needed where 
> a dsa is connected via a fixed phy and uses the mdio bus for config.
> Fixed ptp ref clock calculatins for the stmmac when ptp ref clock
> is running at <= 50Mhz. Also add device tree setting to config
> ptp clk source on socfpga platforms.

Series applied to net-next, thanks.
