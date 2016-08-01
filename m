From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] phy/micrel: Change phy_id_mask for KSZ8721
Date: Sun, 31 Jul 2016 20:37:43 -0700 (PDT)
Message-ID: <20160731.203743.196041762354082839.davem@davemloft.net>
References: <20160729101208.22447-1-alexanders83@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: alexanders83@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbcHADho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 23:37:44 -0400
In-Reply-To: <20160729101208.22447-1-alexanders83@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Stein <alexanders83@web.de>
Date: Fri, 29 Jul 2016 12:12:08 +0200

> There are KSZ8721 PHYs with phy_id 0x00221619. In order to detect them
> as PHY_ID_KSZ8001 compatible while staying different to PHY_ID_KSZ9021
> ignore the last two bits when matching PHY_ID
> 
> Signed-off-by: Alexander Stein <alexanders83@web.de>

Applied.
