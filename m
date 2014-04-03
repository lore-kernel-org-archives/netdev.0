From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] sxgbe: fix driver probe error path and
 driver removal leaks
Date: Thu, 03 Apr 2014 14:54:22 -0400 (EDT)
Message-ID: <20140403.145422.2017892921202259639.davem@davemloft.net>
References: <20140402231343.GC5013@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, dan.carpenter@oracle.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbaDCSwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 14:52:49 -0400
In-Reply-To: <20140402231343.GC5013@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 3 Apr 2014 01:13:43 +0200

> sxgbe_drv_probe:  mdio and priv->hw leaks
> sxgbe_drv_remove: clk and priv->hw leaks
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Also applied, thanks Francois.
