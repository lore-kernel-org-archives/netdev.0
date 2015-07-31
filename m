From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v3] net: phy: add driver for aquantia phy
Date: Fri, 31 Jul 2015 15:31:08 -0700 (PDT)
Message-ID: <20150731.153108.1224798981020759728.davem@davemloft.net>
References: <1438333122-31759-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbGaWbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:31:09 -0400
In-Reply-To: <1438333122-31759-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Fri, 31 Jul 2015 16:58:42 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> This patch added driver to support Aquantia PHYs AQ1202, AQ2104, AQR105,
> AQR405, which accessed through clause 45.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
> changes in v3:
> removed nop routines.
> 
> changes in v2:
> addressed Florian's comments.

Applied to net-next, thanks.
