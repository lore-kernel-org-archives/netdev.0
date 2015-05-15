From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mdio-gpio: Propagate mii_bus.phy_ignore_ta_mask
Date: Thu, 14 May 2015 22:35:25 -0400 (EDT)
Message-ID: <20150514.223525.1002920445610959723.davem@davemloft.net>
References: <1431516939-16589-1-git-send-email-bert@biot.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, jogo@openwrt.org
To: bert@biot.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422918AbbEOCf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:35:26 -0400
In-Reply-To: <1431516939-16589-1-git-send-email-bert@biot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Vermeulen <bert@biot.com>
Date: Wed, 13 May 2015 13:35:39 +0200

> This also changes mii_bus.phy_mask to u32 for consistency.
> 
> Signed-off-by: Bert Vermeulen <bert@biot.com>

Applied, thanks Bert.
