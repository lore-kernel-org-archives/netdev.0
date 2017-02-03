From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmmac: Fix wrong message in
 stmmac_probe_config_dt
Date: Thu, 02 Feb 2017 22:04:14 -0500 (EST)
Message-ID: <20170202.220414.514941128272278213.davem@davemloft.net>
References: <dc9df66b-022f-6a8b-8797-1965fc9b10bb@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, preid@electromag.com.au,
        Joao.Pinto@synopsys.com
To: hkallweit1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38414 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751867AbdBCDEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:04:16 -0500
In-Reply-To: <dc9df66b-022f-6a8b-8797-1965fc9b10bb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiner Kallweit <hkallweit1@gmail.com>
Date: Thu, 2 Feb 2017 08:20:12 +0100

> Most likely a copy & paste error in referenced commit.
> Restore the debug message to what it was before.
> 
> Fixes: f573c0b9c4e0 ("stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform structure")
> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
> ---
> v2:
> - Don't remove the wrong comment but replace it with what
>   was there before the referenced commit.

Applied to net-next.
