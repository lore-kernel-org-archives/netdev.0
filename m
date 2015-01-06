From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl: Add mEMAC MDIO support to XGMAC MDIO
Date: Tue, 06 Jan 2015 17:18:56 -0500 (EST)
Message-ID: <20150106.171856.1589494551491329597.davem@davemloft.net>
References: <1420364162-13109-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@gmail.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbbAFWS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 17:18:58 -0500
In-Reply-To: <1420364162-13109-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Sun, 4 Jan 2015 17:36:02 +0800

> From: Andy Fleming <afleming@gmail.com>
> 
> The Freescale mEMAC supports operating at 10/100/1000/10G, and
> its associated MDIO controller is likewise capable of operating
> both Clause 22 and Clause 45 MDIO buses. It is nearly identical
> to the MDIO controller on the XGMAC, so we just modify that
> driver.
> 
> Portions of this driver developed by:
> 
> Sandeep Singh <sandeep@freescale.com>
> Roy Zang <tie-fei.zang@freescale.com>
> 
> Signed-off-by: Andy Fleming <afleming@gmail.com>
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied, thanks.
