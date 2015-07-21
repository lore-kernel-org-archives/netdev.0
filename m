From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mdio: fix mdio_bus_match for c45 PHY
Date: Tue, 21 Jul 2015 00:17:04 -0700 (PDT)
Message-ID: <20150721.001704.649972038239229587.davem@davemloft.net>
References: <1437127639-48082-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbbGUHRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:17:05 -0400
In-Reply-To: <1437127639-48082-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Fri, 17 Jul 2015 18:07:19 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> We store c45 PHY's id information in c45_ids, so it should be used to
> check the matching between PHY driver and PHY device for c45 PHY.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied, thanks.
